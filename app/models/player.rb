# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Player < ApplicationRecord
  extend CleanupTools

  has_many :rosters
  has_many :teams, through: :rosters
  has_many :batting_stats, through: :rosters
  has_many :pitching_stats, through: :rosters
  has_many :game_batting_stats, through: :rosters
  has_many :game_pitching_stats, through: :rosters
  has_many :transaction_logs, through: :rosters

  after_save :fix_association_names

  scope :names_to_fix, ->{where(check_names: true).where(names_fixed: false)}

  # types
  PITCHER = 1
  BATTER = 2

  PITCHING_POSITIONS = ['sp','cl','mr']
  ADJUSTMENT_SEASON = 1999

  def set_names(saveit = false)
    if((self.first_name.blank? or self.last_name.blank?))
      names = self.name.split(%r{\s+})
      if(names.length > 2)
        self.check_names = true
        # middle inital logic
        if(self.name =~ %r{\.})
          self.last_name = names.pop
          self.first_name = names.join(' ')
        else
          self.first_name = names.shift
          self.last_name = names.join(' ')
        end
      else
        self.check_names = false
        self.first_name = names[0]
        self.last_name = names[1]  
      end

      if(saveit)
        self.save!
      end
    end
    self
  end

  def fix_association_names
    if((!self.first_name.blank? and !self.last_name.blank?))
      if(!self.check_names or self.names_fixed)
        self.rosters.update_all(["first_name = ?, last_name = ?",self.first_name,self.last_name])
        self.game_batting_stats.update_all(["first_name = ?, last_name = ?",self.first_name,self.last_name])
        self.batting_stats.update_all(["first_name = ?, last_name = ?",self.first_name,self.last_name])
        self.game_pitching_stats.update_all(["first_name = ?, last_name = ?",self.first_name,self.last_name])
        self.pitching_stats.update_all(["first_name = ?, last_name = ?",self.first_name,self.last_name])
        self.transaction_logs.update_all(["first_name = ?, last_name = ?",self.first_name,self.last_name])
      end
    end
  end

  def fix_names(first,last)
    self.first_name = first
    self.last_name = last
    self.names_fixed = true
    self.save!
  end

  def mark_name_fixed
    self.names_fixed = true
    self.save!
  end

  def self.create_or_update_from_roster(roster)
    if(player = self.where(buster_id: roster.buster_id).first)
      if(roster.season < player.earliest_season)
        player.earliest_season = roster.season
        player.earliest_season_age = roster.age
      end
      player.save!
    else
      player = Player.new
      player[:buster_id] = roster.buster_id
      player[:name] = roster.name
      player.set_names
      player[:player_type] = position_type(roster.position)
      player[:earliest_season] = roster.season
      player[:earliest_season_age] = roster.age
      player[:bats] = roster.bats
      player[:throws] = roster.throws
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

  def fullname
    name
  end



end