# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Roster < ApplicationRecord
  extend CleanupTools

  belongs_to :team
  belongs_to :player
  has_one :batting_stat
  has_one :pitching_stat
  has_many :game_batting_stats
  has_many :game_pitching_stats
  has_one :real_batting_stat
  has_one :real_pitching_stat
  has_many :transaction_logs
  has_one :batter_playing_time
  has_one :pitcher_playing_time

  before_save  :set_status_code, :set_is_pitcher

  scope :pitchers, -> { where(is_pitcher: true) }
  scope :batters, -> { where(is_pitcher: false) }

  scope :for_season, lambda {|season| where(season: season)}
  scope :by_team, lambda {|team| where(team_id: team.id)}
  scope :active, -> {where(status_code: STATUS_ACTIVE)}
  scope :reserve, -> {where(status_code: STATUS_RESERVE)}
  scope :traded, -> {where(status_code: STATUS_TRADED)}
  scope :current, -> {where.not(status_code: STATUS_TRADED)}


  PITCHING_POSITIONS = ['sp','cl','mr']
  ADJUSTMENT_SEASON = 1999

  # status_codes
  STATUS_ACTIVE = 1
  STATUS_RESERVE = 0
  STATUS_TRADED = -1
  STATUS_PRESENT = 42
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
    when 'present'
      self.status_code = STATUS_PRESENT
    else
      self.status = STATUS_UNKNOWN
    end
  end

  def set_is_pitcher
    self.is_pitcher = PITCHING_POSITIONS.include?(self.position)
  end

  def self.position_list
    self.group(:position).count
  end

  def get_real_batting_stat
    if(rbs = self.real_batting_stat)
      return rbs
    elsif(trade_status == ACQUIRED_TRADE and rbs = RealBattingStat.where(roster_id: original_roster_id).first)
      return rbs
    else
      return nil
    end
  end

  def get_real_pitching_stat
    if(rps = self.real_pitching_stat)
      return rps
    elsif(trade_status == ACQUIRED_TRADE and rps = RealPitchingStat.where(roster_id: original_roster_id).first)
      return rps
    else
      return nil
    end
  end

  def get_total_batting_stat
    bs = self.batting_stat
    if(trade_status == ACQUIRED_TRADE)
      if(tbs = BattingStat.where(season: self.season).where(team_id: BattingStat::MULTIPLE_TEAM).where(player_id: self.player_id).first)
        return tbs
      end
    end
    return bs
  end

  def get_total_pitching_stat
    ps = self.pitching_stat
    if(trade_status == ACQUIRED_TRADE)
      if(tps = PitchingStat.where(season: self.season).where(team_id: PitchingStat::MULTIPLE_TEAM).where(player_id: self.player_id).first)
        return tps
      end
    end
    return ps
  end


  def playing_time
    if(self.is_pitcher?)
      self.pitcher_playing_time
    else
      self.batter_playing_time
    end
  end


  def create_or_update_playing_time
    playing_time_data = {}
    total_games = self.team.records.for_season(self.season).first.gamescount
    playing_time_data['total_games'] = total_games
    if(self.is_pitcher?)
      if(rps = self.get_real_pitching_stat)
        if(!ppt = PitcherPlayingTime.where(season: self.season).where(roster_id: self.id).first)
          ppt = PitcherPlayingTime.new(season: self.season, roster_id: self.id)
        end
        ppt.total_games = total_games
        ppt.actual_ip = rps.ip
        ppt.qualifying_ip = (ppt.actual_ip / 2.to_f).ceil
        if(ps = self.get_total_pitching_stat)
          ppt.ip = ps.ip
        else
          ppt.ip = 0
        end
        need_ip = ppt.qualifying_ip -  ppt.ip
        ppt.qualified = (need_ip >= 0) ? false : true
        ppt.save!
      end
    else
      if(rbs = self.get_real_batting_stat)
        if(!bpt = BatterPlayingTime.where(season: self.season).where(roster_id: self.id).first)
          bpt = BatterPlayingTime.new(season: self.season,  roster_id: self.id)
        end
        bpt.total_games = total_games
        bpt.actual_ab = rbs.ab
        allowed = (rbs.ab / 400.to_f)
        bpt.allowed_percentage = (allowed < 1) ? allowed : 1
        bpt.qualifying_ab = (bpt.actual_ab / 2.to_f).ceil
        bpt.allowed_starts = (bpt.allowed_percentage * 162).ceil
        if(bs = self.get_total_batting_stat)
          bpt.played_percentage = (bs.gs / total_games.to_f).to_f
          bpt.gs = bs.gs
          bpt.ab = bs.ab
          need_ab = bpt.qualifying_ab  -  bpt.ab
          bpt.qualified =  (need_ab >= 0) ? false : true
        else
          bpt.played_percentage = 0
          bpt.gs = 0
          bpt.ab = 0
          bpt.qualified = false
        end
        bpt.save!
      end
    end
  end

  def self.find_roster_for_name_position_team_season(name,position,team_id,season,is_fullname=false)
    player_finder = self.where(season: season)
    if(!team_id.nil?)
      player_finder = player_finder.where(team_id: team_id)
    end

    if(is_fullname)
      player_finder = player_finder.where("name ILIKE ?","%#{name}%")
      startswith = name.first
    else
      namefinder = self.idiotic_shorthand_name_translations(name.dup)
      (lastname,startswith) = namefinder.split(',')
      if(lastname.last =~ %r{[A-Z]})
        startswith = lastname.last
        lastname.chop!
      else
        if !startswith.nil?
          startswith = self.idiotic_shorthand_startswith_translations(startswith)
        end
      end
      nameparts = lastname.split("'")
      finder = nameparts.max_by(&:length)
      end_name = finder.downcase.split(' ').last
      player_finder = player_finder.where("end_name ILIKE ?","%#{end_name}%")
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

  def self.idiotic_shorthand_startswith_translations(startswith)
    if(startswith.length > 1)
      startswith.first
    else
      startswith
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


  def self.create_or_update_for_season(season)
    if(season == 1999)
      self.create_ninety_nine_rosters
    else
      Team.all.each do |team|
        rp = team.roster_parser(season)
        rp.roster.each do |hashkey,player_details|
          create_or_update_roster_player_for_season_by_team(season,team,player_details)
        end
      end

      # get the transaction logs
      TransactionLog.create_or_update_logs_for_season(season)

      # adjust for traded players
      Team.all.each do |team|
        team.create_or_update_traded_rosters_for_season(season)
      end
    end
  end


  def self.create_or_update_roster_player_for_season_by_team(season,team,player_details)
    player = Player.find_by_player_details(season,player_details)
    roster_attributes = player.attributes.merge(player_details)

    allowed_attributes = self.column_names
    allowed_attributes.delete_if {|name| name == 'id'}
    roster_attributes.select!{|name,value| allowed_attributes.include?(name)}

    rp = self.for_season(season).by_team(team).where(player_id: player.id).first

    if(!rp)
      rp = self.new(season: season, team_id: team.id, player_id: player.id)
      rp.assign_attributes(roster_attributes)
      rp.save!
    else
      rp.update_attributes(roster_attributes)
    end
    rp
  end

  def self.create_ninety_nine_rosters
    batting_data = BattingStat.get_batting_data_for_season(1999)
    batting_data.each do |key,batting_details|
      team = Team.abbreviation_finder(batting_details['team'])
      player_details = {}
      player_details['status'] = 'present'
      # exception handling
      if(batting_details['name'] == 'Brian Hunter')
        player_details['name'] = 'Brian Lee Hunter'
      else
        player_details['name'] = batting_details['name']
      end
      player_details['position'] = batting_details['p']
      player_details['age'] = batting_details['age']
      self.create_or_update_roster_player_for_season_by_team(1999,team,player_details)
    end

    # special case for Jerry Hairston
    team = Team.abbreviation_finder('OAK')
    player_details = {}
    player_details['status'] = 'present'
    player_details['name'] = 'Jerry Hairston'
    player_details['position'] = '2b'
    player_details['age'] = 23
    self.create_or_update_roster_player_for_season_by_team(1999,team,player_details)


    pitching_data = PitchingStat.get_pitching_data_for_season(1999)
    pitching_data.each do |key,pitching_details|
      team = Team.abbreviation_finder(pitching_details['team'])
      player_details = {}
      player_details['status'] = 'present'
      player_details['name'] = pitching_details['name']
      player_details['position'] = pitching_details['p']
      player_details['age'] = pitching_details['age']
      self.create_or_update_roster_player_for_season_by_team(1999,team,player_details)
    end
  end

  def self.create_or_update_playing_time_for_season(season)
    self.for_season(season).each do |rp|
      rp.create_or_update_playing_time
    end
  end





end
