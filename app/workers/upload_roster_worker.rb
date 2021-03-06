# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadRosterWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless upload.ready_for_rosters?
    upload.process_rosters!

    SlackIt.post(message: "[UID:#{upload.id}] Starting processing rosters for season #{upload.season}")
    Roster.create_or_update_for_season(upload.season)
    SlackIt.post(message: "[UID:#{upload.id}] Finished processing rosters for season #{upload.season}")
    upload.processed_rosters!
  end
end