# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamPitchingStat < ApplicationRecord
  extend CleanupTools

  belongs_to :team
  
  before_save :set_singles

  scope :for_season, lambda {|season| where(season: season)}

  def self.rebuild_all
    self.dump_data
    Game.available_seasons.reverse.each do |season|
      Team.all.each do |team|
        team.update_team_pitching_stats_for_season(season)
      end
    end
  end

  def set_singles
    if(!self.h3b.blank? and !self.h2b.blank? and !self.hr.blank? and !self.h.blank?)
      self.h1b = (h - (h3b+h2b+hr))
    end
    true
  end
  
end