# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'zip'

class Upload < ApplicationRecord
  include ArchiveUploader::Attachment(:archive)

  state_machine :initial => :not_extracted do

    after_transition any => :ready_for_players do |upload, transition|
      UploadPlayerWorker.perform_async(upload.id)
    end

    after_transition any => :ready_for_rosters do |upload, transition|
      UploadRosterWorker.perform_async(upload.id)
    end

    after_transition any => :ready_for_games do |upload, transition|
      UploadGamesWorker.perform_async(upload.id)
    end

    after_transition any => :ready_for_stats do |upload, transition|
      UploadStatsWorker.perform_async(upload.id)
    end

    after_transition any => :ready_for_game_stats do |upload, transition|
      UploadGameStatsWorker.perform_async(upload.id)
    end

    after_transition any => :finished_processing do |upload, transition|
      if upload.season == Game.current_season
        UploadNotifierWorker.perform_async(upload.id)
      else
        upload.processed!
      end
    end

    event :ready_to_extract do
      transition all => :ready_to_extract
    end

    event :extracting do
      transition ready_to_extract: :extracting
    end

    event :extracted do
      transition [:not_extracted, :extracting] => :ready_for_players
    end

    event :ready_for_players do
      transition all => :ready_for_players
    end

    event :process_players do
      transition ready_for_players: :processing_players
    end

    event :processed_players do
      transition processing_players: :ready_for_rosters
    end

    event :process_rosters do
      transition ready_for_rosters: :processing_rosters
    end

    event :processed_rosters do
      transition processing_rosters: :ready_for_games
    end

    event :process_games do
      transition ready_for_games: :processing_games
    end

    event :processed_games do
      transition processing_games: :ready_for_stats
    end


    event :process_stats do
      transition ready_for_stats: :processing_stats
    end

    event :processed_stats do
      transition processing_stats: :ready_for_game_stats
    end

    event :process_game_stats do
      transition ready_for_game_stats: :processing_game_stats
    end

    event :processed_game_stats do
      transition processing_game_stats: :finished_processing
    end

    event :send_notifications do
      transition finished_processing: :sending_notifications
    end

    event :sent_notifications do
      transition sending_notifications: :processed
    end

    event :processed do
      transition finished_processing: :processed
    end

  end

  belongs_to :owner

  after_create :queue_extraction

  def self.available_seasons
    self.distinct.pluck(:season).sort
  end

  def self.process_players
    self.where("season <> #{Game.current_season}").order(:season,:created_at).all.each do |upload|
      SlackIt.post(message: "[UID:#{upload.id}] Starting processing players for season #{upload.season}")
      Player.create_or_update_for_season_from_dmbdata(upload.season)
      SlackIt.post(message: "[UID:#{upload.id}] Finished processing players for season #{upload.season}")
    end
    # once they are all processed, update status
    self.where("season <> #{Game.current_season}").order(:season).all.each do |upload|
      upload.processed_players
    end
  end

  def self.process_rosters
    self.where("season <> #{Game.current_season}").order(:season).all.each do |upload|
      SlackIt.post(message: "[UID:#{upload.id}] Starting processing rosters for season #{upload.season}")
      Roster.create_or_update_for_season(upload.season)
      SlackIt.post(message: "[UID:#{upload.id}] Finished processing rosters for season #{upload.season}")
    end
    # once they are all processed, update status
    self.where("season <> #{Game.current_season}").order(:season).all.each do |upload|
      upload.processed_rosters
    end
  end


  def queue_extraction
    self.ready_to_extract!
    self.class.delay_for(5.seconds).delayed_extraction(self.id)
    true
  end

  def self.delayed_extraction(record_id)
    if(record = find_by_id(record_id))
      record.extracting!
      record.extract_zip
    end
  end

  def archive_path
    self.archive.storage.path(self.archive.id).to_s
  end

  def archive_filename
    self.archive.metadata['filename']
  end

  def extract_zip
    # unzip to tmp directory
    unzip_to = Dir.mktmpdir
    Zip::File.open(self.archive_path) do |zip_file|
      zip_file.each do |f|
        output_fname = File.basename(f.name)
        fpath = File.join(unzip_to, output_fname)
        zip_file.extract(f, fpath) { true }
      end
    end

    # check for the 1999 index
    index_1999_file = File.join(unzip_to, "orgindex1_1999.htm")
    if(File.exist?(index_1999_file))
      index_file = index_1999_file
    else
      index_file = File.join(unzip_to, "index.htm")
    end

    if(File.exist?(index_file))
      index_data = File.read(index_file)
      doc = Nokogiri::HTML(index_data)
      season_header = doc.search("h2").first.text.strip
      if(season_header =~ %r{^Organization:\s+(\d+)\s+})
        season = $1.to_i
        # exception handling for 2001 season index
        if(season == 2000)
          if(season_header =~ %r{DMB(\d+)})
            season = $1
          end
        end
        self.update_attribute(:season, season)
        move_to = "#{Rails.root}/public/dmbweb/#{self.season}/"
        if(Dir.exist?(move_to))
          FileUtils.remove_dir(move_to, force: true)
        end
        FileUtils.mv(unzip_to, move_to, :force => true)
        # fix perms
        FileUtils.chmod_R(0755,move_to)
        self.extracted!
        return true
      end
    end
    return false
  end


end
