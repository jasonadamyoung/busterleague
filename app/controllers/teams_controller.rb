# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamsController < ApplicationController

  def index
    @team_display = {}
    ['American','National'].each do |league|
      @team_display[league] = {}
      ['East','West'].each do |division|
        @team_display[league][division] = Team.standings(league: league,division: division,season: @season)
      end
    end
  end

  def show
    @team = Team.where(id: params[:id]).first
    if(@season == 'all')
      return render('showall')
    end
  end

  def wingraphs
  end

  def gbgraphs
  end

end
