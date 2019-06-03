# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Standings

  attr_accessor :date, :season, :standings

  def initialize(season,date)
    self.standings = []
    Record.on_season_date(season,date).includes(:team).order("wins_minus_losses DESC").each do |r|
      self.standings << [r.team,r]
    end
  end

  def all
    self.standings
  end

  def by_league(league)
    self.standings.select{|team,record| team.league == league}
  end

  def by_division(league,division)
    self.standings.select{|team,record| team.league == league && team.division == division}
  end

end