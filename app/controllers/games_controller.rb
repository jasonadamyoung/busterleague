# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class GamesController < ApplicationController

  def index
  end

  def show
    @game = Boxscore.where(id: params[:id]).first
  end

  def batting
  end

    
end
