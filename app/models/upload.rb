# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'zip'

class Upload < ApplicationRecord
  has_attached_file :archivefile, {
    url: "/system/:class/:hash.:extension",
    hash_data: ":class/:attachment/:id/:updated_at",
    hash_secret: Settings.upload_hash_key
  }

  validates_attachment_content_type :archivefile, content_type: ["application/zip"]
  validates_uniqueness_of :archivefile_fingerprint

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
  
  def season
    if(self.archivefile_file_name =~ %r{\D*(\d{4})})
      $1.to_i
    else
      Game.current_season
    end
  end


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
    unzip_to = "#{Rails.root}/public/dmbweb/#{self.season}"
    Dir.mkdir(unzip_to) unless Dir.exist?(unzip_to) 
    Zip::File.open(self.archivefile.path) do |zip_file|
      zip_file.each do |f|
        # remove "Web" from file name - ongoing season files are in a "Web" directory
        if(f.name =~ %r{^Web/(.*)})
          output_fname = $1
        # season summary files are in a "YYYY" directory
        elsif(f.name =~ %r{^#{self.season}/(.*)})
          output_fname = $1
        else
          output_fname = f.name
        end
        fpath = File.join(unzip_to, output_fname)
        zip_file.extract(f, fpath) { true }
      end
    end
    true
  end

  def unzip_and_process
    # unzip
    self.extract_zip
    # process
    self.process_upload_data
  end

  def process_upload_data
    self.update_attribute(:processing_status, PROCESSING_STARTED)
    SlackIt.post(message: "Starting processing for : #{self.archivefile_file_name}")
    Team.create_or_update_rosters_for_season(self.season)
    Team.update_batting_stats_for_season(self.season)
    Boxscore.download_and_process_for_season(self.season)
    Record.rebuild(self.season)
    self.update_attributes(processing_status: PROCESSED)
    SlackIt.post(message: "An upload has been processed: #{self.archivefile_file_name}")
  end

end
