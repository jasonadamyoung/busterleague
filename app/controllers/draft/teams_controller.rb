# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamsController < ApplicationController
    before_action :signin_required
  
    def index
      @teams = Team.all
    end

    def show
      @team = Team.find(params[:id])
      @batters = Batter.byrankingvalue(@brv).byteam(@team).order('position,lastname')
      @pitchers = Pitcher.byrankingvalue(@prv).byteam(@team).order('position,lastname')
    end
    
end
