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
      @draft_owner_rank = false
      return
    end

    # always set @draft_owner_rank to false for now
    @draft_owner_rank = false

    # check for owner rank cookie
    # if(!params[:draft_owner_rank].nil?)
    #   @draft_owner_rank = TRUE_VALUES.include?(params[:draft_owner_rank])
    #   logger.debug("params = #{params}")
    #   logger.debug("draft_owner_rank = #{@draft_owner_rank}")
    #   cookies[:draft_owner_rank] = {:value => @draft_owner_rank, :expires => 2.months.from_now}
    # elsif(cookies[:draft_owner_rank])
    #   @draft_owner_rank = TRUE_VALUES.include?(cookies[:draft_owner_rank])
    #   cookies[:draft_owner_rank] = {:value => @draft_owner_rank, :expires => 2.months.from_now}
    # else
    #   @draft_owner_rank = false
    #   cookies[:draft_owner_rank] = {:value => @draft_owner_rank, :expires => 2.months.from_now}
    # end

    position = params[:position] ? params[:position].downcase : 'default'
    position = 'default' if ['allbatters','allpitchers','all'].include?(position)

    # pitching
    if(dopp = @currentowner.draft_owner_position_prefs.pitching.where(prefable_type: 'DraftRankingValue').where(position: position).first)
      @prv = dopp.prefable
    elsif(dopp = @currentowner.draft_owner_position_prefs.pitching.where(prefable_type: 'DraftRankingValue').where(position: 'all').first)
      @prv = dopp.prefable
    else
      @prv = DraftRankingValue.pitching.default
    end

    # batting
    if(dopp = @currentowner.draft_owner_position_prefs.batting.where(prefable_type: 'DraftRankingValue').where(position: position).first)
      @brv = dopp.prefable
    elsif(dopp = @currentowner.draft_owner_position_prefs.batting.where(prefable_type: 'DraftRankingValue').where(position: 'all').first)
      @brv = dopp.prefable
    else
      @brv = DraftRankingValue.batting.default
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

    position = params[:position] ? params[:position].downcase : 'default'
    position = 'default' if ['allbatters','allpitchers','all'].include?(position)

    # pitching
    if(dopp = @currentowner.draft_owner_position_prefs.pitching.where(prefable_type: 'DraftStatPreference').where(position: position).first)
      @psp = dopp.prefable
    elsif(dopp = @currentowner.draft_owner_position_prefs.pitching.where(prefable_type: 'DraftStatPreference').where(position: 'all').first)
      @psp = dopp.prefable
    else
      @psp = DraftStatPreference.pitching.default
    end

    # batting
    if(dopp = @currentowner.draft_owner_position_prefs.batting.where(prefable_type: 'DraftStatPreference').where(position: position).first)
      @bsp = dopp.prefable
    elsif(dopp = @currentowner.draft_owner_position_prefs.batting.where(prefable_type: 'DraftStatPreference').where(position: 'all').first)
      @bsp = dopp.prefable
    else
      @bsp = DraftStatPreference.batting.default
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


  def draft_owner_rank_hash
    {draft_owner_rank: @draft_owner_rank, owner: @currentowner}
  end

  def redirect_to_current_or_root
    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(draft_root_url)
    end
  end

end
