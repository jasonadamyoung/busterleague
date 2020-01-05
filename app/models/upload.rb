# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'zip'

class Upload < ApplicationRecord
  include ArchiveUploader::Attachment(:archive)

  # status values
  NOT_YET_PROCESSED  = 0
  PROCESSING_QUEUED  = 1
  PROCESSING_STARTED = 11
  WILL_NOT_PROCESS   = 21
  PROCESSED          = 42

  PROCESSING_STATUS_STRINGS = {
    NOT_YET_PROCESSED  => "Not yet processed",
    PROCESSING_QUEUED  => "Processing queued",
    PROCESSING_STARTED => "Processing started",
    WILL_NOT_PROCESS   => "Will not process",
    PROCESSED          => "Processed"
  }

  belongs_to :owner

  after_create :check_for_processing

  def check_for_processing
    if(Settings.redis_enabled)
      # let the processing be manual post-create if we aren't backgrounding
      self.queue_unzip_and_process
    end
    true
  end

  def processing_status_to_s
    PROCESSING_STATUS_STRINGS[self.processing_status]
  end

  def queue_unzip_and_process
    self.update_attribute(:processing_status, PROCESSING_QUEUED)
    if(!Settings.redis_enabled)
      self.unzip_and_process
    else
      self.class.delay_for(5.seconds).delayed_unzip_and_process(self.id)
    end
  end

  def self.delayed_unzip_and_process(record_id)
    if(record = find_by_id(record_id))
      record.unzip_and_process
    end
  end

  def extract_zip
    # unzip to tmp directory
    unzip_to = Dir.mktmpdir
    Zip::File.open(self.archivefile.path) do |zip_file|
      zip_file.each do |f|
        output_fname = File.basename(f.name)
        fpath = File.join(unzip_to, output_fname)
        zip_file.extract(f, fpath) { true }
      end
    end

    index_file = File.join(unzip_to, "index.htm")
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
        return true
      end
    end
    return false
  end

  def unzip_and_process
    # unzip
    self.extract_zip
    # process
    self.process_upload_data
    Team.send_owner_emails_for_season(self.season)
  end

  def process_upload_data
    self.update_attribute(:processing_status, PROCESSING_STARTED)
    SlackIt.post(message: "Starting processing for : #{self.archivefile_file_name}")
    GameResult.create_or_update_results_for_season(self.season)
    SlackIt.post(message: "... Game Results created/updated for Season : #{self.season}")
    if(self.season == 1999)
      GameResult.create_data_records_for_season(self.season)
      SlackIt.post(message: "... Game Result data records created/updated for Season : #{self.season}")
    else
      TransactionLog.create_or_update_logs_for_season(self.season)
      SlackIt.post(message: "... Transaction logs created/updated for Season : #{self.season}")
      Team.create_or_update_rosters_for_season(self.season)
      SlackIt.post(message: "... Rosters created/updated for Season : #{self.season}")
    end
    Team.update_batting_stats_for_season(self.season)
    BattingStat.update_total_batting_stats_for_season(self.season)
    SlackIt.post(message: "... Batting stats created/updated for Season: #{self.season}")
    Team.update_pitching_stats_for_season(self.season)
    PitchingStat.update_total_pitching_stats_for_season(self.season)
    SlackIt.post(message: "... Pitching stats created/updated for Season: #{self.season}")

    if(self.season != 1999)
      Boxscore.download_and_store_for_season(self.season)
      SlackIt.post(message: "... Boxscores created for Season: #{self.season}")
      Boxscore.create_data_records_for_season(self.season)
      SlackIt.post(message: "... Boxscores data records created for Season: #{self.season}")
    end
    Record.create_or_update_season_records(self.season)
    SlackIt.post(message: "... Season records rebuilt for Season : #{self.season}")
    Roster.create_or_update_playing_time_for_season(self.season)
    SlackIt.post(message: "... Playing time created/updated for Season: #{self.season}")
    Record.create_or_update_season_records('all')
    SlackIt.post(message: "... Total records rebuilt for all seasons")
    self.update_attributes(processing_status: PROCESSED, latest_game_date: Game.latest_date(self.season))
    SlackIt.post(message: "An upload has been processed: #{self.archivefile_file_name}")
  end



end
