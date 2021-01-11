# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class MainController < ApplicationController
    before_action :signin_required
  
    def index
      @teams = Team.all
    end

    def search
        if (!params[:q].nil? and !params[:q].empty? and params[:q].size >= 2)
            @playerlist = Player.notdrafted.searchplayers(params[:q]).order(:lastname).limit(3)
        end
        render(:layout => false)
    end
    
    def rounds
        @draftpicks = DraftPick.order('overallpick ASC').page(params[:page])
    end
end