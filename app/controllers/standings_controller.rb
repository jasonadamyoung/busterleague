# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class StandingsController < ApplicationController

  def index
    @standings = Standings.new(@season,@date)
  end

end