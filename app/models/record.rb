# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Record < ApplicationRecord
  extend CleanupTools

	belongs_to :team
  
  before_save :set_win_minus_losses

  scope :winners, -> { where("wins / games::float > .5") }
  scope :losers, -> { where("wins / games::float <= .5") }
  scope :on_date, lambda {|date| where("date = ?",date)}
  scope :for_season, lambda {|season| where(season: season)}
  scope :final_for_season, ->{where(final_season_record: true)}

  ALL_SEASON = 0

  def self.on_season_date(season,date)
    if(season == 'all')
      season = ALL_SEASON
    end
    where(season: season).where("date = ?",date)
  end

  def set_win_minus_losses
    self.wins_minus_losses = self.wins - self.losses
  end

  def self.create_or_update_records_for_season_and_dates(season,dates = 'default')
    if(dates == 'default')
      dates = (Game.earliest_date(season)..Game.latest_date(season)).to_a
    end

    dates.each do |date|
      Team.all.each do |team|
        record = self.create_or_update_for_team_and_date(season,team,date)
        # streak
        gameslist_through_season_date = team.games.through_season_date(season,date).order(:date)
        streak_code = ''
        streak_count = 0
        gameslist_through_season_date.each do |game|
          game_code = (game.win? ? 'W' : 'L')
          if(game_code == streak_code)
            streak_count += 1
          else
            streak_code = game_code
            streak_count = 1
          end
        end
        record.update_column(:streak, "#{streak_code}#{streak_count}")
      end

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
  end

  def self.create_or_update_for_team_and_date(season,team,date)
    latest_date_for_season = Game.latest_date(season)
    if(!record_for_date = self.where(season: season).where(:date => date).where(:team_id => team.id).first)
      record_for_date = Record.new(season: season, date: date, team: team)
    end

    record_for_date.home_games = team.games.home.through_season_date(season,date).count
    record_for_date.road_games = team.games.away.through_season_date(season,date).count
    record_for_date.games =  record_for_date.home_games + record_for_date.road_games
    record_for_date.wins = team.games.wins.through_season_date(season,date).count
    record_for_date.home_wins = team.games.home.wins.through_season_date(season,date).count
    record_for_date.road_wins = team.games.away.wins.through_season_date(season,date).count
    record_for_date.losses = record_for_date.games - record_for_date.wins
    record_for_date.home_rf = team.games.home.through_season_date(season,date).sum(:runs)
    record_for_date.home_ra = team.games.home.through_season_date(season,date).sum(:opponent_runs)
    record_for_date.road_rf = team.games.away.through_season_date(season,date).sum(:runs)
    record_for_date.road_ra = team.games.away.through_season_date(season,date).sum(:opponent_runs)
    record_for_date.rf = record_for_date.home_rf + record_for_date.road_rf
    record_for_date.ra = record_for_date.home_ra + record_for_date.road_ra
    record_for_date.final_season_record = (date == latest_date_for_season)
    record_for_date.save!
    record_for_date
  end

  def records_by_opponent
    if(read_attribute(:records_by_opponent).blank?)
      self.set_records_by_opponent
    end
    read_attribute(:records_by_opponent)
  end

  def set_records_by_opponent
    rbo = {}
    games = self.team.games.through_season_date(season,date)
    games.each do |g|
      rbo[g.opponent_id] ||= {:wins => 0, :losses => 0}
      if(g.win?)
        rbo[g.opponent_id][:wins] += 1
      else
        rbo[g.opponent_id][:losses] += 1
      end
    end
    self.update_attribute(:records_by_opponent, rbo)
  end

  def streak
    (n = read_attribute(:streak)) ? n : 0
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

  def last_ten
    gameslist = team.games.for_season(self.season).through_date(self.date).order("date DESC").limit(10)
    last_wins = 0; last_losses = 0;
    gameslist.each do |game|
      if(game.win?)
        last_wins += 1;
      else
        last_losses += 1;
      end
    end
    "#{last_wins} - #{last_losses}"
  end

  def expected_pct
    if(self.gamescount > 0)
      exponent = ((rf + ra) / gamescount )**0.287
     (rf**(exponent)) / ( (rf**(exponent)) + (ra**(exponent)) )
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
    total_record_against_opponents(Team.human)
  end

  def computer_wl
    total_record_against_opponents(Team.computer)
  end

  def winners_wl
    total_record_against_opponents(self.class.winning_teams_for_season_date(self.season,self.date))
  end

  def losers_wl
    total_record_against_opponents(self.class.losing_teams_for_season_date(self.season,self.date))
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


  def self.winning_teams_for_season_date(season,date)
    self.winners.on_season_date(season,date).map(&:team)
  end


  def self.losing_teams_for_season_date(season,date)
    self.losers.on_season_date(season,date).map(&:team)
  end


  def self.create_or_update_final_record_for_season(season)
    latest_date_for_season = Game.latest_date(season)
    self.create_or_update_records_for_season_and_dates(season,[latest_date_for_season])
  end


  def self.rebuild(season)
    self.create_or_update_records_for_season_and_dates(season)
  end

end
