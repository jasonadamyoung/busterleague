# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::StatsController < Draft::BaseController
  before_action :noidletimeout


  def index
  end

  def pitching
    @pitching_stats = []
    DefinedStat.pitching_statlines.each do |pitching_stat|
     @pitching_stats << DraftStatDistribution.create_or_update_from_defined_stat(pitching_stat)
    end
  end

  def batting
    @batting_stats = []
    DefinedStat.batting_statlines.each do |batting_stat|
      @batting_stats << DraftStatDistribution.create_or_update_from_defined_stat(batting_stat)
    end
  end
end