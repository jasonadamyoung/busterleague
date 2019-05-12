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

  scope :for_season, lambda {|season| where(season: season)}

  # location
  LOCATION_HOME = 1
  LOCATION_AWAY = 2

  def self.rebuild_all
    self.dump_data
    Boxscore.find_each do |boxscore|
      boxscore.create_game_batting_stats
    end
  end

  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

end