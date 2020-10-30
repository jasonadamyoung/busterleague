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

  scope :check_names, ->{where(check_names: true)}
  scope :names_to_fix, ->{where(check_names: true).where(names_fixed: false)}

  # types
  PITCHER = 1
  BATTER = 2

  PITCHING_POSITIONS = ['sp','cl','mr']
  ADJUSTMENT_SEASON = 1999
  ADJUSTMENT_OFFSET = 43

  def self.dump_all_data
    self.dump_data
    Roster.dump_data
    PitchingStat.dump_data
    BattingStat.dump_data
    BattingStat.dump_data
    GameBattingStat.dump_data
    GamePitchingStat.dump_data
    TransactionLog.dump_data
    TeamBattingStat.dump_data
    TeamPitchingStat.dump_data
    BatterPlayingTime.dump_data
    PitcherPlayingTime.dump_data
  end

  def is_pitcher?
    self.player_type == PITCHER
  end

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

  def self.find_by_player_details(season,player_details)
    buster_id = make_buster_id(season,player_details)
    self.where(buster_id: buster_id).first
  end

  def self.make_buster_id(season,player_details)
    age = player_details['age']
    name = player_details['name']
    position = player_details['position']

    adjusted_age = age - (season - ADJUSTMENT_SEASON) + ADJUSTMENT_OFFSET
    "#{name.downcase.gsub(%r{[^a-z]},'')}_#{position_type(position)}_#{adjusted_age}"
  end

  def self.create_or_update_from_player_details(season,player_details)
    buster_id = make_buster_id(season,player_details)
    if(player = self.where(buster_id: buster_id).first)
      if(season < player.earliest_season)
        player.earliest_season = season
        player.earliest_season_age = player_details['age']
      end
      player.bats = player_details['bats'] if !player_details['bats'].nil?
      player.throws = player_details['throws'] if !player_details['throws'].nil?
      player.save!
    else
      player = Player.new
      player[:buster_id] = buster_id
      player[:name] = player_details['name']
      player[:end_name] = player_details['name'].split(' ').last
      player[:player_type] = position_type(player_details['position'])
      player[:earliest_season] = season
      player[:earliest_season_age] = player_details['age']
      player[:bats] = player_details['bats'] || ''
      player[:throws] = player_details['throws'] || ''
      player.set_names
      player.save!
    end
  end

  def self.create_or_update_for_season_from_dmbdata(season)
    if(season == 1999)
      self.create_ninety_nine_players
    else
      Team.all.each do |t|
        rp = t.roster_parser(season)
        rp.roster.each do |hashkey,player_details|
          create_or_update_from_player_details(season,player_details)
        end
      end
    end
  end

  def self.create_ninety_nine_players
    batting_data = BattingStat.get_batting_data_for_season(1999)
    batting_data.each do |key,batting_details|
      player_details = {}
      # exception handling
      if(batting_details['name'] == 'Brian Hunter')
        player_details['name'] = 'Brian Lee Hunter'
      else
        player_details['name'] = batting_details['name']
      end
      player_details['position'] = batting_details['p']
      player_details['age'] = batting_details['age']
      # don't have bats/throws for 1999
      self.create_or_update_from_player_details(1999,player_details)
    end

    # special case for Jerry Hairston
    player_details = {}
    player_details['name'] = 'Jerry Hairston'
    player_details['position'] = '2b'
    player_details['age'] = 23
    self.create_or_update_from_player_details(1999,player_details)


    pitching_data = PitchingStat.get_pitching_data_for_season(1999)
    pitching_data.each do |key,pitching_details|
      player_details = {}
      player_details['name'] = pitching_details['name']
      player_details['position'] = pitching_details['p']
      player_details['age'] = pitching_details['age']
      self.create_or_update_from_player_details(1999,player_details)
    end
  end

end