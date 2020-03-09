# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class RosterParserWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless ( upload.processing_status == Upload::READY_FOR_ROSTERS )

    SlackIt.post(message: "Starting rosters for season #{upload.season} (Upload ID: #{upload.id})...")
    Roster.create_or_update_for_season(upload.season)
    SlackIt.post(message: ".... finished processing rosters for season #{upload.season} (Upload ID: #{upload.id})")
    upload.set_status(Upload::PROCESSED_ROSTERS)
  end
end