# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'zip'

class Upload < ApplicationRecord
  include ArchiveUploader::Attachment(:archive)

  # status values
  NOT_YET_EXTRACTED    = 0
  EXTRACTION_QUEUED    = 1
  EXTRACTION_FAILED    = 2
  PROCESSING_FAILED    = 3
  READY_FOR_ROSTERS    = 11
  READY_FOR_PROCESSING = 21
  PROCESSING_STARTED   = 31
  PROCESSED            = 42

  PROCESSING_STATUS_STRINGS = {
    NOT_YET_EXTRACTED    => "Not yet extracted",
    EXTRACTION_QUEUED    => "Extraction queued",
    EXTRACTION_FAILED    => "Extraction failed",
    PROCESSING_FAILED    => "Processing failed",
    READY_FOR_ROSTERS    => "Ready to process rosters",
    READY_FOR_PROCESSING => "Ready for processing",
    PROCESSING_STARTED   => "Processing started",
    PROCESSED            => "Processed"
  }

  belongs_to :owner

  after_create :queue_extraction
  after_update :check_for_processing

  def self.available_seasons
    self.distinct.pluck(:season).sort
  end

  def reset_status(status: NOT_YET_EXTRACTED)
    self.update_attribute(:processing_status, status)
  end

  def processing_status_to_s
    PROCESSING_STATUS_STRINGS[self.processing_status]
  end

  def check_for_processing
    if(self.processing_status == PROCESSED && self.season == Game.current_season)
      # send background emails
      # Team.send_owner_emails_for_season(self.season)
    elsif(self.processing_status >= READY_FOR_PROCESSING)
      # do background stuff
    elsif(self.processing_status == READY_FOR_ROSTERS && self.season == Game.current_season)
      # current season? background it
    end
  end

  def queue_extraction
    self.update_attribute(:processing_status, EXTRACTION_QUEUED)
    self.class.delay_for(5.seconds).delayed_extraction(self.id)
    true
  end

  def self.delayed_extraction(record_id)
    if(record = find_by_id(record_id))
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
        self.update_attribute(:processing_status, READY_FOR_ROSTERS)
        return true
      end
    end
    self.update_attribute(:processing_status, EXTRACTION_FAILED)
    return false
  end


  # def process_upload_data
  #   self.update_attribute(:processing_status, PROCESSING_STARTED)
  #   SlackIt.post(message: "Starting processing for : #{self.archive_filename}")
  #   GameResult.create_or_update_results_for_season(self.season)
  #   SlackIt.post(message: "... Game Results created/updated for Season : #{self.season}")
  #   if(self.season == 1999)
  #     GameResult.create_ninety_nine_games
  #     SlackIt.post(message: "... Game Result data records created/updated for Season : #{self.season}")
  #   else
  #     TransactionLog.create_or_update_logs_for_season(self.season)
  #     SlackIt.post(message: "... Transaction logs created/updated for Season : #{self.season}")
  #     Team.create_or_update_rosters_for_season(self.season)
  #     SlackIt.post(message: "... Rosters created/updated for Season : #{self.season}")
  #   end
  #   Team.update_batting_stats_for_season(self.season)
  #   BattingStat.update_total_batting_stats_for_season(self.season)
  #   SlackIt.post(message: "... Batting stats created/updated for Season: #{self.season}")
  #   Team.update_pitching_stats_for_season(self.season)
  #   PitchingStat.update_total_pitching_stats_for_season(self.season)
  #   SlackIt.post(message: "... Pitching stats created/updated for Season: #{self.season}")
  #   if(self.season == 1999)
  #     Roster.create_ninety_nine_rosters
  #     BattingStat.fix_roster_ids
  #     PitchingStat.fix_roster_ids
  #     SlackIt.post(message: "... Handled 1999 Rosters")
  #   end

  #   if(self.season != 1999)
  #     Boxscore.download_and_store_for_season(self.season)
  #     SlackIt.post(message: "... Boxscores created for Season: #{self.season}")
  #     if(Settings.process_boxscore_data)
  #       Boxscore.create_data_records_for_season(self.season)
  #       SlackIt.post(message: "... Boxscores data records created for Season: #{self.season}")
  #     end
  #   end
  #   Record.create_or_update_season_records(self.season)
  #   SlackIt.post(message: "... Season records rebuilt for Season : #{self.season}")
  #   Roster.create_or_update_playing_time_for_season(self.season)
  #   SlackIt.post(message: "... Playing time created/updated for Season: #{self.season}")
  #   Record.create_or_update_season_records('all')
  #   SlackIt.post(message: "... Total records rebuilt for all seasons")
  #   self.update_attributes(processing_status: PROCESSED, latest_game_date: Game.latest_date(self.season))
  #   SlackIt.post(message: "An upload has been processed: #{self.archive_filename}")
  # end



end
