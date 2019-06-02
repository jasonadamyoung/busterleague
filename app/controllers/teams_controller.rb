# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamsController < ApplicationController

  def index
    @standings = Standings.new(@season,@date)
    @team_display = {}
    ['American','National'].each do |league|
      @team_display[league] = {}
      ['East','West'].each do |division|
        @team_display[league][division] = @standings.by_division(league,division)
      end
    end
  end

  def show
    @team = Team.where(id: params[:id]).first
    if(@season == 'all')
      return render('showall')
    end
  end

  def playingtime
    if(params[:id])
    @team = Team.where(id: params[:id]).first
    @gamescount = @team.records.final_for_season(@season).first.gamescount
    @batters = @team.rosters.for_season(@season).current.batters.includes(:player).order(:status,:last_name)
    @pitchers = @team.rosters.for_season(@season).current.pitchers.includes(:player).order(:status,:last_name)
    else
      @batters = Roster.for_season(@season).current.batters.includes(:player,:real_batting_stat,:real_pitching_stat).joins(:team).order("teams.name",:last_name)
      @pitchers = Roster.for_season(@season).current.pitchers.includes(:player,:real_batting_stat,:real_pitching_stat).joins(:team).order("teams.name",:last_name)
      return render('fullplayingtime')
    end
  end

  def wingraphs
  end

  def gbgraphs
  end

end
