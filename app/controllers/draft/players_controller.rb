# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class PlayersController < ApplicationController
  before_action :signin_required

  def draft
    begin
      @player = Player.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to find player.'
      return redirect_to(root_url)
    end
    @draftaction = params[:draftaction].nil? ? 'none' : params[:draftaction]
    @draftpick = params[:draftpick].nil? ? DraftPick::CURRENTPICK : params[:draftpick]
    @domcontainer = params[:domcontainer]

    case @draftaction
    when 'draft'
      if(@player.draftstatus != Player::DRAFT_STATUS_NOTDRAFTED)
        flash[:error] = "#{@player.fullname} is already drafted!"
      else
        @player.draftplayer(:draftpick => @draftpick)
        flash[:success] = "Drafted #{@player.fullname}"
        SlackIt.post(message: "#{@player.fullname} has been drafted")
      end
    when 'release'
      if(@player.draftstatus != Player::DRAFT_STATUS_DRAFTED)
        flash[:error] = "#{@player.fullname} was not drafted!"
      else
        @player.returntodraft
        flash[:warning] = "Returned #{@player.fullname} to draft"
        SlackIt.post(message: "#{@player.fullname} has returned to the draft")
      end
    else
      # do nothing
    end

    return redirect_to(root_url)
  end

  def setdraftstatus
    # all the work for this is actually done in the
    # check_for_draftstatus before_action - we'll just
    # redirect here.
    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(root_url)
    end
  end

  
  def sethighlight
    @player = Player.where(id: params[:id]).first
    if(@player)
      @wanted = @currentowner.wanteds.where(player_id: @player.id).first
      if(@wanted)
        @wanted.update_attribute(:highlight,params[:highlight])
      end
    end

    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(root_url)
    end
  end

  def setnotes
    @player = Player.where(id: params[:id]).first
    if(@player)
      @wanted = @currentowner.wanteds.where(player_id: @player.id).first
      if(@wanted)
        notes = (@player.class == Pitcher) ? params[:pitcher][:notes] : params[:batter][:notes]
        @wanted.update_attribute(:notes,notes)
      end
    end

    respond_to do |format|
      format.html do
        if(!params[:currenturi].nil?)
          return redirect_to(Base64.decode64(params[:currenturi]))
        else
          return redirect_to(root_url)
        end
      end
      format.json { respond_with_bip(@player) }
    end
  end

  def index
    if (params[:position].blank? or params[:position] == 'all')
      @position = 'all'
      @showtype = 'all'
      @playerlist = Player.includes(:team).draftstatus(@draftstatus,@currentowner.team).sorting({owner_rank: @owner_rank,owner: @currentowner},@brv,@prv).page(params[:page])
    elsif(params[:position] == 'allpitchers')
      @showtype = 'pitchers'
      @position = 'allpitchers'
      @playerlist = Pitcher.includes(:team).draftstatus(@draftstatus,@currentowner.team).sorting({owner_rank: @owner_rank,owner: @currentowner},@prv).includes(:statline).page(params[:page])
    elsif(params[:position].downcase == 'sp' or params[:position].downcase == 'rp')
      @showtype = 'pitchers'
      @position = params[:position].downcase
      @playerlist = Pitcher.includes(:team).draftstatus(@draftstatus,@currentowner.team).sorting({owner_rank: @owner_rank,owner: @currentowner},@prv).where("players.position = '#{@position}'").includes(:statline).page(params[:page])
    elsif(params[:position] == 'allbatters')
      @position = 'allbatters'
      @showtype = 'batters'
      @playerlist = Batter.includes(:team).draftstatus(@draftstatus,@currentowner.team).sorting({owner_rank: @owner_rank,owner: @currentowner},@brv).includes(:statline).page(params[:page])
    else
      @showtype = 'batters'
      @position = params[:position].downcase
      @playerlist = Batter.includes(:team).draftstatus(@draftstatus,@currentowner.team).sorting({owner_rank: @owner_rank,owner: @currentowner},@brv).fieldergroup(@position).page(params[:page])
    end

  end

  def show
    if not params[:id].nil?
      @player = Player.where(id: params[:id]).first
      if (@player.nil?)
        flash[:warning] = 'Player not found.'
        return redirect_to(players_url)
      else

        begin
          referer_uri = URI.parse(request.referer)
          if(referer_uri.path =~ %r{^/players})
            @referer_path = referer_uri.path
          end
        rescue
          # nothing
        end

        @attributes = @player.statline.attributes.sort

        if(@player.class.name == 'Batter')
          core_stats = [['age',-1],['warp',1],['rc27',1],['eqa',1],['ops',1],['opsplus',1],['pa',1],['lops',1],['rops',1]]
          position = 'all'
        else
          core_stats = [['age',-1],['gs',1],['innings',1],['wins',1],['losses',-1],['saves',1],['era',-1],['eraplus',1],['whip',-1],['hitsnine',-1],['hrnine',-1],['knine',1],['walksnine',-1],['ops',-1],['lops',-1],['rops',-1]]
          position = @player.position
        end
      end
    else
      return redirect_to(players_url)
    end
  end

  def wanted
    if(@currentowner.wanteds.count > 0)
      @batters = Batter.byrankingvalue_and_wantedowner(@brv,@currentowner)
      @pitchers = Pitcher.byrankingvalue_and_wantedowner(@prv,@currentowner)

    end
  end

  def findplayer
    if (!params[:q].nil? and !params[:q].empty? and params[:q].size >= 2)
      @playerlist = Player.searchplayers(params[:q]).order(:lastname)
    end
    respond_to do |wants|
      wants.html { render :action => 'findplayer'}
      wants.js { render :action => 'findplayer', :layout => false}
    end
  end

  def wantplayer
    @player = Player.find(params[:id])
    if (@player.nil?)
      flash[:warning] = 'Player not found.'
    else
      @attributes = @player.statline.attributes.sort
      Wanted.create(:player => @player, :owner => @currentowner, :notes => params[:notes], :highlight => params[:highlight])
      flash[:success] = 'Added to wanted players'
      SlackIt.post(message: "#{@currentowner.nickname} added a player to their wanted players list")
    end
    return redirect_to(player_url(@player))
  end

  def set_owner_rank
    @player = Player.find(params[:id])
    if(owner_rank = @player.owner_ranks.where(owner_id: @currentowner.id).first and !params[:value].blank?)
      owner_rank.update_attribute(:overall, params[:value])
      returninformation = {'msg' => 'OK!'}
      return render :json => returninformation.to_json, :status => 200
    else
      returninformation = {'msg' => 'Value is blank'}
      return render :json => returninformation.to_json, :status => 400
    end

  end

  def removewant
    begin
      @player = Player.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to find player.'
      return redirect_to(root_url)
    end
    @wantaction = params[:want].nil? ? 'none' : params[:want]

    case @wantaction
    when 'no'
      @currentowner.wantedplayers.delete(@player)
      flash[:warning] = 'Removed from wanted players'
      SlackIt.post(message: "#{@currentowner.nickname} removed a player from their wanted players list")
    else
      # do nothing
    end
    return redirect_to(player_url(@player))
  end

end
