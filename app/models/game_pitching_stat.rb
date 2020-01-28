# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class GamePitchingStat < ApplicationRecord
  extend CleanupTools

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team
  belongs_to :opposing_team, :class_name => 'Team'
  belongs_to :boxscore

  scope :for_season, lambda {|season| where(season: season)}

  # location
  LOCATION_HOME = 1
  LOCATION_AWAY = 2

  def home?
    self.location == LOCATION_HOME
  end

  def self.rebuild_all
    self.dump_data
    Boxscore.find_each do |boxscore|
      boxscore.create_game_pitching_stats
    end
  end

  def fix_roster_id
    if(roster = Roster.find_roster_for_name_position_team_season(self.name,
                                                                 'p',
                                                                 self.team_id,
                                                                 self.season))
      self.update_attribute(:roster_id,roster.id)
    end
  end

  def self.fix_roster_ids
    self.where(roster_id: 0).find_each do |gps|
      gps.fix_roster_id
    end
  end

end