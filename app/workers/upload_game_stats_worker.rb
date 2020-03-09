# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadGameStatsWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless ( upload.processing_status == Upload::READY_FOR_STATS )

    SlackIt.post(message: "Starting processing game stats for season #{upload.season} (Upload ID: #{upload.id})...")
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
    SlackIt.post(message: ".... finished processing game stats for season #{upload.season} (Upload ID: #{upload.id})")
    upload.set_status(Upload::PROCESSED_STATS)
  end
end