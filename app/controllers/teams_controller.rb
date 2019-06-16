# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamsController < ApplicationController

  def index
    @standings = Standings.new(@season)
    @team_display = {}
    ['American','National'].each do |league|
      @team_display[league] = {}
      ['East','West'].each do |division|
        @team_display[league][division] = @standings.by_division(league,division)
      end
    end
  end

  def show
    @team = Team.find_by!(id: params[:id])
    if(@season == 'all')
      return render('showall')
    end
  end

  def playingtime
    if(params[:id])
      @team = Team.find_by!(id: params[:id])
      @gamescount = @team.records.for_season(@season).first.gamescount
    else
      @teams = Team.order(:name)
      return render('fullplayingtime')
    end
  end

  def wingraphs
  end

  def gbgraphs
  end

end
