# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class ApplicationController < ActionController::Base
  include AuthenticationSystem
  has_mobile_fu false

  before_action :check_for_rebuild_in_progress, :set_date
  before_action :signin_optional
  helper_method :home_url
  helper_method :home_path
  helper_method :humanize_bytes

  TRUE_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'yes','YES','y','Y']
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE','no','NO','n','N']

  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
    payload[:owner_id] = @currentowner if @currentowner
  end

  def set_date
    if(params[:date])
      begin
        @date = Date.parse(params[:date])
      rescue
        @date = Game.latest_date
      end
    else
      @date = Game.latest_date
    end
  end

  def check_for_rebuild_in_progress
    if(rebuild = Rebuild.latest)
      if(rebuild.in_progress?)
        flash.now[:warning] = 'The Busterleague stats are currently being rebuilt. Refresh the site in a few minutes.'
      end
    end
    true
  end


  def home_url
    root_url
  end

  def home_path
    root_path
  end

  # code from: https://github.com/ripienaar/mysql-dump-split
  def humanize_bytes(bytes,defaultstring='')
    if(!bytes.nil? and bytes != 0)
      units = %w{B KB MB GB TB}
      e = (Math.log(bytes)/Math.log(1024)).floor
      s = "%.1f"%(bytes.to_f/1024**e)
      s.sub(/\.?0*$/,units[e])
    else
      defaultstring
    end
  end


end
