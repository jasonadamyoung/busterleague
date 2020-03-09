# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadNotifierWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless ( upload.processing_status == Upload::PROCESSED )

    SlackIt.post(message: "[UID:#{upload.id}] Sending owner emails for season #{upload.season}")
    Team.send_owner_emails_for_season(upload.season)
    SlackIt.post(message: "[UID:#{upload.id}] Finished sending owner emails for season #{upload.season}")
  end
end
