# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamPitchingStat < ApplicationRecord
  extend CleanupTools
  belongs_to :team
  scope :for_season, lambda {|season| where(season: season)}

  def self.rebuild_all(post_to_slack = true)
    SlackIt.post(message: "Rebuilding team pitching stats") if post_to_slack
    self.dump_data
    Game.available_seasons.reverse.each do |season|
      SlackIt.post(message: " Starting rebuild for season #{season}") if post_to_slack
      Team.all.each do |team|
        SlackIt.post(message: "... Rebuilding #{season} stats for #{team.abbrev} ...") if post_to_slack
        team.update_team_pitching_stats_for_season(season)
      end
    end
  end
end