# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class LeadersController < ApplicationController

  def index
  end

  def batting
    @limit = params[:limit] || 10
    @columns = params[:columns] || 5
    @stat_fields = DefinedStat.batting.core.order(:default_display_order).each_slice(@columns).to_a 
  end

  def pitching
  end

end