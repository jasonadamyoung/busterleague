# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Player < ApplicationRecord

  has_many :rosters
  has_many :game_batting_stats
  has_many :game_pitching_stats


  # types
  PITCHER = 1
  BATTER = 2

  PITCHING_POSITIONS = ['sp','cl','mr']
  ADJUSTMENT_SEASON = 2000

  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def self.create_or_update_from_roster(roster)
    if(player = self.where(buster_id: roster.buster_id).first)
      if(roster.season < player.earliest_season)
        player.earliest_season = roster.season
        player.earliest_season_age = roster.age
      end
      player.positions = (player.positions + [roster.position]).uniq
      player.teams = (player.teams + [roster.team_id]).uniq
      player.seasons = (player.seasons + [roster.season]).uniq
      player.save!
    else
      player = Player.new
      player[:buster_id] = roster.buster_id
      player[:name] = roster.name
      player[:player_type] = position_type(roster.position)
      player[:earliest_season] = roster.season
      player[:earliest_season_age] = roster.age
      player[:bats] = roster.bats
      player[:throws] = roster.throws
      player[:positions] = [roster.position]
      player[:teams] = [roster.team_id]
      player[:seasons] = [roster.season]
      player.save!
    end
    player
  end

  def self.position_type(position)
    if(PITCHING_POSITIONS.include?(position.downcase))
      PITCHER
    else
      BATTER
    end
  end

  def self.duplicate_names
    duplicate_hash = Player.group(:name).having('count(players.id) > 1').count
    duplicate_hash.keys.each do |name|
      pp self.where(name: name).all
    end
  end



end