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
    Stat::PITCHING_DIRECTIONS.keys.sort.each do |statname|
     @pitching_stats << Stat.find_or_create(DraftStatDistribution::PITCHER,statname)
    end
  end

  def batting
    @batting_stats = []
    Stat::BATTING_DIRECTIONS.keys.sort.each do |statname|
     @batting_stats << Stat.find_or_create(DraftStatDistribution::BATTER,statname)
    end
  end


end