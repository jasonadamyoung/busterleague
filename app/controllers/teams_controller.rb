# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamsController < ApplicationController

  def index
    @teams = Team.all
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
