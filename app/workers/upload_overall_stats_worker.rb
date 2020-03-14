# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class UploadOverallStatsWorker
  include Sidekiq::Worker

  def perform
    SlackIt.post(message: "Starting processing overall stats...")
    Record.create_or_update_season_records('all')
    SlackIt.post(message: ".... finished processing overall stats")
  end
end