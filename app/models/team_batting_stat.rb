# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamBattingStat < ApplicationRecord
  extend CleanupTools

  belongs_to :team

  before_save :set_singles

  scope :for_season, lambda {|season| where(season: season)}

  def self.rebuild_all()
    self.dump_data
    Game.available_seasons.reverse.each do |season|
      Team.all.each do |team|
        team.update_team_batting_stats_for_season(season)
      end
    end
  end

  def set_singles
    self.h1b = (h - (h3b+h2b+hr))
  end

end