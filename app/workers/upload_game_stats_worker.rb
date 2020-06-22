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

    raise UploadError unless upload.ready_for_game_stats?
    upload.process_game_stats!

    SlackIt.post(message: "Starting processing game stats for season #{upload.season} (Upload ID: #{upload.id})...")
    Boxscore.create_data_records_for_season(upload.season)
    SlackIt.post(message: ".... finished processing game stats for season #{upload.season} (Upload ID: #{upload.id})")
    upload.processed_game_stats!
  end
end