# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadStatsWorker
  include Sidekiq::Worker

  def perform(upload_id)
    begin
      upload = Upload.find(upload_id)
    rescue ActiveRecord::RecordNotFound => error
      Rollbar.log('error', e)
      return false
    end

    raise UploadError unless ( upload.processing_status == Upload::READY_FOR_STATS )

    SlackIt.post(message: "[UID:#{upload.id}] Starting processing stats for season #{upload.season}")
    Team.update_batting_stats_for_season(self.season)
    BattingStat.update_total_batting_stats_for_season(self.season)
    Team.update_pitching_stats_for_season(self.season)
    PitchingStat.update_total_pitching_stats_for_season(self.season)
    SlackIt.post(message: "[UID:#{upload.id}] Finished processing stats for season #{upload.season}")
    upload.set_status(Upload::PROCESSED_STATS)
  end
end