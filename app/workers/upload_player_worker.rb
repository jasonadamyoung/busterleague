# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadPlayerWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless upload.ready_for_players?
    upload.process_players!

    SlackIt.post(message: "[UID:#{upload.id}] Starting processing players for season #{upload.season}")
    Player.create_or_update_for_season_from_dmbdata(upload.season)
    SlackIt.post(message: "[UID:#{upload.id}] Finished processing players for season #{upload.season}")
    upload.processed_players!
  end
end