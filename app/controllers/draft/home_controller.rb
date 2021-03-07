# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::HomeController < Draft::BaseController

  def index
    @showsearchresults = true
    @teams = Team.all
  end

  def rounds
    @draftpicks = DraftPick.order('overallpick ASC').page(params[:page])
  end

end