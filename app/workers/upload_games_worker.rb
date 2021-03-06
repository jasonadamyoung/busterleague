# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadGamesWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless upload.ready_for_games?
    upload.process_games!

    SlackIt.post(message: "[UID:#{upload.id}] Starting processing games for season #{upload.season}")
    Game.create_or_update_for_season(upload.season)
    Record.create_or_update_season_records(upload.season)
    SlackIt.post(message: "[UID:#{upload.id}] Finished processing games for season #{upload.season}")
    upload.processed_games!

  end
end