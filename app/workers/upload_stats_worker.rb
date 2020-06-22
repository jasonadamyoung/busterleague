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

    raise UploadError unless upload.ready_for_stats?
    upload.process_stats!

    SlackIt.post(message: "[UID:#{upload.id}] Starting processing stats for season #{upload.season}")
    Team.update_batting_stats_for_season(upload.season)
    BattingStat.update_total_batting_stats_for_season(upload.season)
    Team.update_pitching_stats_for_season(upload.season)
    PitchingStat.update_total_pitching_stats_for_season(upload.season)
    # update playing time
    Roster.create_or_update_playing_time_for_season(upload.season)
    SlackIt.post(message: "[UID:#{upload.id}] Finished processing stats for season #{upload.season}")
    upload.processed_stats!
  end
end