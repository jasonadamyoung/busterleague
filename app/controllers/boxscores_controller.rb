# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class BoxscoresController < ApplicationController

  def index
  end

  def show
    @boxscore = Boxscore.find_by!(id: params[:id])
  end

end
