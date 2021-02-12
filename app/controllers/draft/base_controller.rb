# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::BaseController < ApplicationController
  before_action :signin_required
  before_action :set_draft_mode
  before_action :check_for_draft_season
  before_action :check_for_ranking
  before_action :check_for_draftstatus
  before_action :check_for_stat_preference

  def set_draft_mode
    @draftmode = true
  end

  def check_for_draft_season
    @allowed_draft_seasons = [2020] unless @allowed_draft_seasons
    @latest_draft_season = [2020] unless @latest_draft_season

    if(!params[:draft_season].nil?)
      if(params[:draft_season] == 'all')
        @draft_season = 'all'
      elsif(@allowed_draft_seasons.include?(params[:draft_season].to_i))
        @draft_season = params[:draft_season].to_i
      else
        @draft_season = @latest_draft_season
      end
    else
      @draft_season = @latest_draft_season
    end
    return true
  end

  def check_for_ranking
    # bail if no currentowner
    if(!@currentowner)
      @prv = DraftRankingValue.pitching.default
      @brv = DraftRankingValue.batting.default
      return
    end

    # pitching
    if(params[:prv] and (rv = DraftRankingValue.where(id: params[:prv].to_i).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @prv = rv
        cookies[:prv] = {:value => @prv.id, :expires => 2.months.from_now}
      else
        @prv = DraftRankingValue.pitching.default
      end
    elsif(cookies[:prv] and (rv = DraftRankingValue.where(id: cookies[:prv]).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @prv = rv
        cookies[:prv] = {:value => @prv.id, :expires => 2.months.from_now}
      else
        @prv = DraftRankingValue.pitching.default
        cookies[:prv] = {:value => @prv.id, :expires => 2.months.from_now}
      end
    else
      @prv = DraftRankingValue.pitching.default
      cookies[:prv] = {:value => @prv.id, :expires => 2.months.from_now}
    end

    # batting
    if(params[:brv] and (rv = DraftRankingValue.where(id: params[:brv].to_i).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @brv = rv
        cookies[:brv] = {:value => @brv.id, :expires => 2.months.from_now}
      else
        @brv = DraftRankingValue.batting.default
      end
    elsif(cookies[:brv] and (rv = DraftRankingValue.where(id: cookies[:brv]).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @brv = rv
        cookies[:brv] = {:value => @brv.id, :expires => 2.months.from_now}
      else
        @brv = DraftRankingValue.batting.default
        cookies[:brv] = {:value => @brv.id, :expires => 2.months.from_now}
      end
    else
      @brv = DraftRankingValue.batting.default
      cookies[:brv] = {:value => @brv.id, :expires => 2.months.from_now}
    end
    return true
  end

  def check_for_stat_preference
    # bail if no currentowner
    if(!@currentowner)
      @psp = DraftStatPreference.pitching.default
      @bsp = DraftStatPreference.batting.default
      return
    end

    # pitching
    if(params[:psp] and (sp = DraftStatPreference.where(id: params[:psp].to_i).first))
      if(sp.owner == @currentowner or sp.owner == Owner.computer)
        @psp = sp
        cookies[:psp] = {:value => @psp.id, :expires => 2.months.from_now}
      else
        @psp = DraftStatPreference.pitching.default
      end
    elsif(cookies[:psp] and (rv = DraftStatPreference.where(id: cookies[:psp]).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @psp = rv
        cookies[:psp] = {:value => @psp.id, :expires => 2.months.from_now}
      else
        @psp = DraftStatPreference.pitching.default
        cookies[:psp] = {:value => @psp.id, :expires => 2.months.from_now}
      end
    else
      @psp = DraftStatPreference.pitching.default
      cookies[:psp] = {:value => @psp.id, :expires => 2.months.from_now}
    end

    # batting
    if(params[:bsp] and (rv = DraftStatPreference.where(id: params[:bsp].to_i).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @bsp = rv
        cookies[:bsp] = {:value => @bsp.id, :expires => 2.months.from_now}
      else
        @bsp = DraftStatPreference.batting.default
      end
    elsif(cookies[:bsp] and (rv = DraftStatPreference.where(id: cookies[:bsp]).first))
      if(rv.owner == @currentowner or rv.owner == Owner.computer)
        @bsp = rv
        cookies[:bsp] = {:value => @bsp.id, :expires => 2.months.from_now}
      else
        @bsp = DraftStatPreference.batting.default
        cookies[:bsp] = {:value => @bsp.id, :expires => 2.months.from_now}
      end
    else
      @bsp = DraftStatPreference.batting.default
      cookies[:bsp] = {:value => @bsp.id, :expires => 2.months.from_now}
    end
    return true
  end


  def check_for_draftstatus
    if(!params[:draftstatus].nil?)
      @draftstatus = params[:draftstatus]
      cookies[:draftstatus] = {:value => @draftstatus, :expires => 2.months.from_now}
      ActiveRecord::Base::logger.debug "@draftstatus = #{@draftstatus}"
    elsif(!cookies[:draftstatus].nil?)
      @draftstatus = cookies[:draftstatus]
    else
      @draftstatus = DraftPlayer::ME_ME_ME
    end
    return true
  end

  def set_idletimeout
    begin
      draft_date = Date.parse(Settings.buster_draft_date)
      @idletimeout = (Date.today == draft_date)
    rescue
      @idletimeout = false
    end
  end

  def noidletimeout
    @idletimeout = false
  end

end
