# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Standings

  attr_accessor :season, :standings

  def initialize(season)
    self.standings = []
    Record.for_season(season).includes(:team).order("wins_minus_losses DESC").each do |r|
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