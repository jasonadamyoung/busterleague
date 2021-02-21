# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::HomeController < Draft::BaseController

  def index
    @teams = Team.all
  end

  def search
    if (!params[:q].nil? and !params[:q].empty? and params[:q].size >= 2)
        @playerlist = DraftPlayer.notdrafted.searchplayers(params[:q]).order(:last_name).limit(3)
    end
    render(:layout => false)
  end

  def rounds
    @draftpicks = DraftPick.order('overallpick ASC').page(params[:page])
  end

end