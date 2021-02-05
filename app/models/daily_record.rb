# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DailyRecord < ApplicationRecord
  include ActiveModel::AttributeAssignment
  include CleanupTools


	belongs_to :team

  before_save :set_win_minus_losses

  scope :winners, -> { where("games > 0").where("wins / games::float > .5") }
  scope :losers, -> { where("games > 0").where("wins / games::float <= .5") }
  scope :on_date, lambda {|date| where("date = ?",date)}
  scope :for_season, lambda {|season| where(season: season)}
  scope :final_for_season, lambda {|season| for_season(season).where(final_season_record: true)}

  ALL_SEASON = 0


  def self.on_season_date(season,date)
    if(season == 'all' or season == 0)
      season = ALL_SEASON
    end
    for_season(season).on_date(date)
  end

  def set_win_minus_losses
    self.wins_minus_losses = self.wins - self.losses
  end


  def gameslist
    self.team.team_games.through_season_date(self.season,self.date)
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
    idlist['human'] = Team.human.pluck(:id).map(&:to_s)
    idlist['computer'] = Team.computer.pluck(:id).map(&:to_s)
    idlist['winners'] = self.class.winners.on_season_date(self.season,self.date).pluck(:team_id).map(&:to_s)
    idlist['losers'] = self.class.losers.on_season_date(self.season,self.date).pluck(:team_id).map(&:to_s)
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

  def self.set_wl_groups_for_season_and_date(season,date)
    self.on_season_date(season,date).each do |record|
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


  def self.set_gb_for_season_and_date(season,date)
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
          records[team] = team.records.on_season_date(season,date).first
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


  def self.create_or_update_records_for_season_and_dates(season,dates = 'default')
    if(dates == 'default')
      dates = (Game.earliest_date(season)..Game.latest_date(season)).to_a
    end

    dates.each do |date|
      Team.all.each do |team|
        record = self.create_or_update_for_team_and_date(season,team,date)
        record.set_streak
        record.set_last_ten
        record.set_records_by_opponent
      end

      self.set_gb_for_season_and_date(season,date)
      self.set_wl_groups_for_season_and_date(season,date)
    end
  end

  def self.create_or_update_for_team_and_date(season,team,date)
    latest_date_for_season = Game.latest_date(season)
    if(!record_for_date = self.where(season: season).where(:date => date).where(:team_id => team.id).first)
      record_for_date = Record.new(season: season, date: date, team: team)
    end

    record_for_date.home_games = team.team_games.home.through_season_date(season,date).count
    record_for_date.road_games = team.team_games.away.through_season_date(season,date).count
    record_for_date.games =  record_for_date.home_games + record_for_date.road_games
    record_for_date.wins = team.team_games.wins.through_season_date(season,date).count
    record_for_date.home_wins = team.team_games.home.wins.through_season_date(season,date).count
    record_for_date.road_wins = team.team_games.away.wins.through_season_date(season,date).count
    record_for_date.losses = record_for_date.games - record_for_date.wins
    record_for_date.home_rf = team.team_games.home.through_season_date(season,date).sum(:runs)
    record_for_date.home_ra = team.team_games.home.through_season_date(season,date).sum(:opponent_runs)
    record_for_date.road_rf = team.team_games.away.through_season_date(season,date).sum(:runs)
    record_for_date.road_ra = team.team_games.away.through_season_date(season,date).sum(:opponent_runs)
    record_for_date.rf = record_for_date.home_rf + record_for_date.road_rf
    record_for_date.ra = record_for_date.home_ra + record_for_date.road_ra
    record_for_date.final_season_record = (date == latest_date_for_season)
    record_for_date.save!
    record_for_date
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
    self.gamescount > 0 ? (self.wins/self.gamescount) : 0
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

  def human_wl
    wl_for_group('human')
  end

  def computer_wl
    wl_for_group('computer')
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



  def self.create_or_update_final_record_for_season(season)
    latest_date_for_season = Game.latest_date(season)
    self.create_or_update_records_for_season_and_dates(season,[latest_date_for_season])
  end


  def self.rebuild(season)
    self.create_or_update_records_for_season_and_dates(season)
  end

end
