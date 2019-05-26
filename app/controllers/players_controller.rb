# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class PlayersController < ApplicationController


  def index
  end

  def show
    @player = Player.where(id: params[:id]).first
    if(@season == 'all')
      return render('showall')
    end
  end

end
