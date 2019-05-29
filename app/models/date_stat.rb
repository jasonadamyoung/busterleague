# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DateStat

  attr_accessor :date, :team, :record_for_date, :season

  def initialize(options = {})
    self.season = options[:season] || Settings.current_season
    self.date = options[:date] || Game.latest_date(self.season)
    self.team = options[:team]
    self.record_for_date = self.team.records.on_season_date(season,date).first
  end

  def streak
    record_for_date.try(:streak) || 0
  end

  def wins
    record_for_date.try(:wins) || 0
  end

  def gamescount
    record_for_date.try(:games) || 0
  end

  def losses
    record_for_date.try(:losses) || 0
  end

  def win_pct
    self.gamescount > 0 ? (self.wins/self.gamescount) : 0
  end

  def rf
    record_for_date.try(:rf) || 0
  end

  def ra
    record_for_date.try(:ra) || 0
  end

  def gb
    record_for_date.try(:gb) || 0
  end

  def league_gb
    record_for_date.try(:league_gb) || 0
  end

  def overall_gb
    record_for_date.try(:overall_gb) || 0
  end

  def wins_minus_losses
    record_for_date.try(:wins_minus_losses)
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
    g = record_for_date.try(:home_games) || 0
    w =  record_for_date.try(:home_wins) || 0
    [w,g-w]
  end

  def road_wl
    g = record_for_date.try(:road_games) || 0
    w =  record_for_date.try(:road_wins) || 0
    [w,g-w]
  end

  def human_wl
    total_record_against_opponents(Team.human)
  end

  def computer_wl
    total_record_against_opponents(Team.computer)
  end

  def winners_wl
    total_record_against_opponents(winning_teams)
  end

  def losers_wl
    total_record_against_opponents(losing_teams)
  end

  def records_by_opponent(forceupdate = false)
    if(!@records_by_opponent or forceupdate)
      @records_by_opponent = {}
      games = team.games.through_season_date(season,date)
      games.each do |g|
        @records_by_opponent[g.opponent_id] ||= {:wins => 0, :losses => 0}
        if(g.win?)
          @records_by_opponent[g.opponent_id][:wins] += 1
        else
          @records_by_opponent[g.opponent_id][:losses] += 1
        end
      end
    end
    @records_by_opponent
  end

  def record_against_opponents(opponents)
    opponent_ids = opponents.map(&:id)
    filtered_records = records_by_opponent.reject{|id,record| !(opponent_ids.include?(id))}
    filtered_records
  end

  def total_record_against_opponents(opponents)
    wins = 0; losses = 0;
    record_against_opponents(opponents).each do |id,record|
      wins += record[:wins]
      losses += record[:losses]
    end
    {:wins => wins, :losses => losses}
  end


  def winning_teams
    Record.winners.on_season_date(season,date).map(&:team)
  end


  def losing_teams
    Record.losers.on_season_date(season,date).map(&:team)
  end

end
