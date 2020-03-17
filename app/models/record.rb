# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Record < ApplicationRecord
  include ActiveModel::AttributeAssignment
  extend CleanupTools

  belongs_to :team
  before_save :set_win_minus_losses

  scope :winners, -> { where("games > 0").where("wins / games::float > .5") }
  scope :losers, -> { where("games > 0").where("wins / games::float <= .5") }
  scope :for_season, lambda {|season| where(season: season)}

  ALL_SEASON = 0

  def set_win_minus_losses
    self.wins_minus_losses = self.wins - self.losses
  end

  def team_season
    self.team.team_seasons.for_season(self.season).first
  end

  def gameslist
    self.team.team_games.for_season(self.season)
  end

  def set_records_by_opponent
    rbo = {}
    self.gameslist.each do |g|
      rbo[g.opponent_id] ||= {'wins' => 0, 'losses' => 0}
      if(g.win?)
        rbo[g.opponent_id]['wins'] += 1
      else
        rbo[g.opponent_id]['losses'] += 1
      end
    end
    self.update_attribute(:records_by_opponent, rbo)
    self.update_attribute(:wl_groups, wl_groups)
  end

  def wl_group_idlist
    idlist = {}
    idlist['winners'] = self.class.winners.for_season(self.season).pluck(:team_id).map(&:to_s)
    idlist['losers'] = self.class.losers.for_season(self.season).pluck(:team_id).map(&:to_s)
    idlist
  end

  def set_wl_groups
    wl_groups = {'human' => {},'computer' => {}, 'winners' => {}, 'losers' => {}}
    idlist = self.wl_group_idlist

    records_by_opponent.each do |id,wl|
      idlist.each do |key,ids|
        if ids.include?(id)
          wl_groups[key][id] = wl
        end
      end
    end
    self.update_attribute(:wl_groups, wl_groups)
  end

  def self.set_wl_groups_for_season(season)
    self.for_season(season).each do |record|
      record.set_wl_groups
    end
  end

  # this is inefficient as all get out, I really
  # need to work out how to go backwards
  def set_streak
    # streak
    streak_code = ''
    streak_count = 0
    self.gameslist.order("date").each do |game|
      game_code = (game.win? ? 'W' : 'L')
      if(game_code == streak_code)
        streak_count += 1
      else
        streak_code = game_code
        streak_count = 1
      end
    end
    self.update_column(:streak, "#{streak_code}#{streak_count}")
  end

  def set_last_ten
    last_wins = 0; last_losses = 0;
    self.gameslist.order("date DESC").limit(10).each do |game|
      if(game.win?)
        last_wins += 1;
      else
        last_losses += 1;
      end
    end
    self.update_attribute(:last_ten, [last_wins,last_losses])
  end


  def self.set_gb_for_season(season)
    # gamesback
    overall_records = {}
    leagues = Team.group(:league).count(:league)
    leagues.keys.each do |league|
      league_records = {}
      divisions = Team.where(:league => league).group(:division).count(:division)
      divisions.keys.each do |division|
        teamlist = Team.where(:league => league).where(:division => division).load
        records = {}
        teamlist.each do |team|
          records[team] = team.records.for_season(season).first
          league_records[team] = records[team]
          overall_records[team] = records[team]
        end

        maxwml = records.values.map(&:wins_minus_losses).max
        records.each do |team,record|
          record.update_column(:gb, (maxwml - record.wins_minus_losses) / 2.to_f)
        end
      end

      maxwml = league_records.values.map(&:wins_minus_losses).max
      league_records.each do |team,record|
        record.update_column(:league_gb, (maxwml - record.wins_minus_losses) / 2.to_f)
      end
    end

    maxwml = overall_records.values.map(&:wins_minus_losses).max
    overall_records.each do |team,record|
      record.update_column(:overall_gb, (maxwml - record.wins_minus_losses) / 2.to_f)
    end
  end


  def self.create_or_update_season_records(season)
    Team.all.each do |team|
      record = self.create_or_update_for_season_and_team(season,team)
      record.set_streak
      record.set_last_ten
      record.set_records_by_opponent
    end

    self.set_gb_for_season(season)
    self.set_wl_groups_for_season(season)
 end

  def self.create_or_update_for_season_and_team(season,team)
    if(!season_record = self.where(season: season).where(:team_id => team.id).first)
      season_record = Record.new(season: season, team: team)
    end

    season_record.home_games = team.team_games.home.for_season(season).count
    season_record.road_games = team.team_games.away.for_season(season).count
    season_record.games =  season_record.home_games + season_record.road_games
    season_record.wins = team.team_games.wins.for_season(season).count
    season_record.home_wins = team.team_games.home.wins.for_season(season).count
    season_record.road_wins = team.team_games.away.wins.for_season(season).count
    season_record.losses = season_record.games - season_record.wins
    season_record.home_rf = team.team_games.home.for_season(season).sum(:runs)
    season_record.home_ra = team.team_games.home.for_season(season).sum(:opponent_runs)
    season_record.road_rf = team.team_games.away.for_season(season).sum(:runs)
    season_record.road_ra = team.team_games.away.for_season(season).sum(:opponent_runs)
    season_record.rf = season_record.home_rf + season_record.road_rf
    season_record.ra = season_record.home_ra + season_record.road_ra
    season_record.save!
    season_record
  end



  def streak
    (n = read_attribute(:streak)) ? n : 0
  end

  def last_ten
    (n = read_attribute(:last_ten)) ? n : [0,0]
  end

  def wins
    (n = read_attribute(:wins)) ? n : 0
  end

  def gamescount
    self.try(:games) || 0
  end

  def losses
    (n = read_attribute(:losses)) ? n : 0
  end

  def win_pct
    self.gamescount > 0 ? (self.wins/self.gamescount.to_f) : 0
  end

  def rf
    (n = read_attribute(:rf)) ? n : 0
  end

  def ra
    (n = read_attribute(:ra)) ? n : 0
  end

  def gb
    (n = read_attribute(:gb)) ? n : 0
  end

  def league_gb
    (n = read_attribute(:league_gb)) ? n : 0
  end

  def overall_gb
    (n = read_attribute(:overall_gb)) ? n : 0
  end

  def wins_minus_losses
    (n = read_attribute(:wins_minus_losses)) ? n : 0
  end


  def expected_pct
    if(self.gamescount > 0)
      exponent = ((rf + ra) / gamescount.to_f )**0.287
     (rf**(exponent)) / ( (rf**(exponent)) + (ra**(exponent)) ).to_f
    else
      0
    end
  end

  def expected_wl
    x_wins = (expected_pct * gamescount).round
    x_losses = gamescount - x_wins
    [x_wins,x_losses]
  end

  def home_wl
    g = self.try(:home_games) || 0
    w =  self.try(:home_wins) || 0
    [w,g-w]
  end

  def road_wl
    g = self.try(:road_games) || 0
    w =  self.try(:road_wins) || 0
    [w,g-w]
  end

  def winners_wl
    wl_for_group('winners')
  end

  def losers_wl
    wl_for_group('losers')
  end

  def wl_for_group(group)
    if(self.wl_groups.keys.include?(group))
      {
        'wins' => self.wl_groups[group].values.map{|h| h['wins']}.sum,
        'losses' => self.wl_groups[group].values.map{|h| h['losses']}.sum,
      }
    else
      nil
    end
  end

  def record_against_opponents(opponents)
    opponent_ids = opponents.map(&:id)
    filtered_records = records_by_opponent.reject{|id,record| !(opponent_ids.include?(id.to_i))}
    filtered_records
  end

  def total_record_against_opponents(opponents)
    wins = 0; losses = 0;
    record_against_opponents(opponents).each do |id,record|
      wins += record['wins']
      losses += record['losses']
    end
    {:wins => wins, :losses => losses}
  end

end
