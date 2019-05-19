# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class GameBattingStat < ApplicationRecord

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team
  belongs_to :opposing_team, :class_name => 'Team'
  belongs_to :boxscore

  before_save :set_singles

  scope :for_season, lambda {|season| where(season: season)}
  scope :four_homer_games, -> {where("hr >= 4")}
  scope :six_hit_games, -> {where("h >= 6")}
  scope :cycles, ->{where('h1b >= 1').where('h2b >= 1').where('h3b >=1').where('hr >= 1')}

  # location
  LOCATION_HOME = 1
  LOCATION_AWAY = 2

  def set_singles
    self.h1b = (h - (h3b+h2b+hr))
  end

  def self.rebuild_all
    self.dump_data
    Boxscore.find_each do |boxscore|
      boxscore.create_game_batting_stats
    end
  end

  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def fix_roster_id
    if(roster = Roster.find_roster_for_name_position_team_season(self.name,
                                                                 self.position,
                                                                 self.team_id,
                                                                 self.season))
      self.update_attribute(:roster_id,roster.id)
    end
  end

  def self.fix_roster_ids
    self.where(roster_id: 0).find_each do |gbs|
      gbs.fix_roster_id
    end
  end


end