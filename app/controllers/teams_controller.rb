# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamsController < ApplicationController
  skip_before_action :check_for_rebuild_in_progress,  only: [:index]

  def index
    if(@rebuild = Rebuild.latest and @rebuild.in_progress?)
      return render :template => 'welcome/rebuild_in_progress'
    else
      @teams = Team.all
    end
  end

  def show
    @team = Team.where(id: params[:id]).first
  end

  def wingraphs
  end

  def gbgraphs
  end

  def dmb
  end

end
