# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Roster < ApplicationRecord

  belongs_to :team
  belongs_to :player, optional: true


  before_save  :set_status_code
  after_create :create_or_update_player

  scope :pitchers, -> { where(position: ['cl','mr','sp']) }
  scope :for_season, lambda {|season| where(season: season)}
  scope :by_team, lambda {|team| where(team_id: team.id)}
  scope :active, -> {where(status_code: STATUS_ACTIVE)}
  scope :reserve, -> {where(status_code: STATUS_RESERVE)}
  scope :traded, -> {where(status_code: STATUS_TRADED)}

  
  ADJUSTMENT_SEASON = 2000

  # status_codes
  STATUS_ACTIVE = 1
  STATUS_RESERVE = 0
  STATUS_TRADED = -1
  STATUS_UNKNOWN = 999

  # trade_status_codes
  NOT_TRADED = 0
  TRADED = 1
  ACQUIRED_TRADE = 2


  def set_status_code
    case self.status
    when 'reserve'
      self.status_code = STATUS_RESERVE
    when 'active'
      self.status_code = STATUS_ACTIVE
    when 'traded'
      self.status_code = STATUS_TRADED
    else
      self.status = STATUS_UNKNOWN
    end
  end


  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def self.position_list
    self.group(:position).count
  end


  def buster_id
    "#{self.name.downcase.gsub(%r{[^a-z]},'')}_#{Player.position_type(self.position)}_#{self.adjusted_age}"
  end

  def adjusted_age
    self.age - (self.season - Roster::ADJUSTMENT_SEASON) + 42
  end

  def create_or_update_player
    player = Player.create_or_update_from_roster(self)
    self.update_attribute(:player_id, player.id)
  end

  def self.find_roster_for_name_position_team_season(name,position,team_id,season,is_fullname=false)
    if(is_fullname)
      player_finder = self.where(season: season).where(team_id: team_id).where("name ILIKE ?","%#{name}%")
      startswith = name.first
    else
      namefinder = self.idiotic_shorthand_name_translations(name.dup)
      (lastname,startswith) = namefinder.split(',')
      if(lastname.last =~ %r{[A-Z]})
        startswith = lastname.last
        lastname.chop!
      end 
      nameparts = lastname.split("'")
      finder = nameparts.max_by(&:length)
      end_name = finder.downcase.split(' ').last
      player_finder = self.where(season: season).where(team_id: team_id).where("end_name ILIKE ?","%#{end_name}%")
    end
    if(position == 'p')
      player_finder = player_finder.pitchers
    end

    if(found_players = player_finder.all)
      if(found_players.size == 1)
        return found_players[0]
      elsif(found_players.size > 1)
        # found more than one
        found_players.each do |roster_player|
          matcher = Regexp.new("^#{startswith}")
          if(roster_player.name =~ matcher)
            return roster_player
          end
        end
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.match_team_season_names(team_id,season,names_hash,have_fullnames=false)
    match_data = {}
    names_hash.each do |name,position|
      if(rp = self.find_roster_for_name_position_team_season(name,position,team_id,season,have_fullnames))
        match_data[name] = rp.id
      else
        match_data[name] = 0
      end
    end
    match_data
  end

  def self.idiotic_shorthand_name_translations(name)
    case name
    when "H'lndswrth"
      "Hollandsworth"
    when "Ichiro"
      "Suzuki"
    when "DelosSntos"
      "Santos"
    when "LoDuca"
      "Duca"
    else
      name
    end
  end

  def self.map_stats_to_name_hash(stats,is_pitching = false)
    name_hash = {}
    if(is_pitching)
      stats.keys.each do |name|
        name_hash[name] = 'p'
      end
    else
      stats.each do |name,stats|
        if(stats['position'])
          name_hash[name] = stats['position']
        elsif(stats['p'])
          name_hash[name] = stats['p']
        else
          name_hash[name] = 'b'
        end
      end
    end
    name_hash
  end


  def self.create_or_update_roster_player_for_season_by_team(season,team,player_details)
    rp = self.for_season(season).by_team(team).where(name: player_details['name']).first
    if(!rp)
      rp = self.new(season: season, team_id: team.id)
      rp.assign_attributes(player_details)
      rp.save!
    else
      rp.update_attributes(player_details)
    end
    rp
  end
  

end
