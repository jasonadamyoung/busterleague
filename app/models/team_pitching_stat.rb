# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamPitchingStat < ApplicationRecord
  extend CleanupTools

  belongs_to :team
  
  scope :for_season, lambda {|season| where(season: season)}

  def self.rebuild_all
    self.dump_data
    Game.available_seasons.reverse.each do |season|
      Team.all.each do |team|
        team.update_team_pitching_stats_for_season(season)
      end
    end
  end
end