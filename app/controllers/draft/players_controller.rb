# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Draft::PlayersController < Draft::BaseController
  helper_method :is_searchpage_request?


  def draft
    begin
      @player = DraftPlayer.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to find player.'
      return redirect_to(draft_root_url)
    end
    @draftaction = params[:draftaction].nil? ? 'none' : params[:draftaction]
    @draftpick = params[:draftpick].nil? ? DraftPick::CURRENTPICK : params[:draftpick]
    @domcontainer = params[:domcontainer]

    case @draftaction
    when 'draft'
      if(@player.draftstatus != DraftPlayer::DRAFT_STATUS_NOTDRAFTED)
        flash[:error] = "#{@player.fullname} is already drafted!"
      else
        @player.draftplayer(:draftpick => @draftpick)
        draft_pick_notify
        flash[:success] = "Drafted #{@player.fullname}"
        SlackIt.post(message: "#{@player.fullname} has been drafted")
      end
    when 'release'
      if(@player.draftstatus != DraftPlayer::DRAFT_STATUS_DRAFTED)
        flash[:error] = "#{@player.fullname} was not drafted!"
      else
        @player.returntodraft
        draft_pick_notify
        flash[:warning] = "Returned #{@player.fullname} to draft"
        SlackIt.post(message: "#{@player.fullname} has returned to the draft")
      end
    else
      # do nothing
    end

    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(draft_root_url)
    end
  end

  def setdraftstatus
    # all the work for this is actually done in the
    # check_for_draftstatus before_action - we'll just
    # redirect here.
    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(draft_root_url)
    end
  end


  def sethighlight
    @player = DraftPlayer.where(id: params[:id]).first
    if(@player)
      @wanted = @currentowner.draft_wanteds.where(draft_player_id: @player.id).first
      if(@wanted)
        @wanted.update_attribute(:highlight,params[:highlight])
      end
    end

    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(draft_root_url)
    end
  end

  def setnotes
    @player = DraftPlayer.where(id: params[:id]).first
    if(@player)
      @wanted = @currentowner.draft_wanteds.where(draft_player_id: @player.id).first
      if(@wanted)
        notes = (@player.class == DraftPitcher) ? params[:draft_pitcher][:notes] : params[:draft_batter][:notes]
        @wanted.update_attribute(:notes,notes)
      end
    end

    respond_to do |format|
      format.html do
        if(!params[:currenturi].nil?)
          return redirect_to(Base64.decode64(params[:currenturi]))
        else
          return redirect_to(draft_root_url)
        end
      end
      format.json { respond_with_bip(@player) }
    end
  end

  def index
    @experimental = is_experimental? ? true : false

    if (params[:position].blank? or params[:position] == 'all')
      @position = 'all'
      @showtype = 'all'
      @playerlist = DraftPlayer.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: (@bdorp and @pdorp), ranking_values: [@brv,@prv]).page(params[:page])
    elsif(params[:position] == 'allpitchers')
      @showtype = 'pitchers'
      @position = 'allpitchers'
      if(@experimental)
        @displaystats = DefinedStat.draft_columns(DefinedStat::PITCHER)
        @playerlist = DraftPitcher.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: @pdorp, ranking_values: [@prv])
      else
        @playerlist = DraftPitcher.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: @pdorp, ranking_values: [@prv]).page(params[:page])
      end
    elsif(params[:position].downcase == 'sp' or params[:position].downcase == 'rp')
      @showtype = 'pitchers'
      @position = params[:position].downcase
      @playerlist = DraftPitcher.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: @pdorp, ranking_values: [@prv]).page(params[:page])
    elsif(params[:position] == 'allbatters')
      @position = 'allbatters'
      @showtype = 'batters'
      if(@experimental)
        @displaystats = DefinedStat.draft_columns(DefinedStat::BATTER)
        @playerlist = DraftBatter.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: @bdorp, ranking_values: [@brv])
      else
        @playerlist = DraftBatter.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: @bdorp, ranking_values: [@brv]).page(params[:page])
      end
    else
      @showtype = 'batters'
      @position = params[:position].downcase
      @playerlist = DraftBatter.playerlist(owner: @currentowner, draftstatus: @draftstatus, position: @position, owner_rank: @bdorp, ranking_values: [@brv]).page(params[:page])
    end
  end

  def show
    if not params[:id].nil?
      @player = DraftPlayer.where(id: params[:id]).first
      if (@player.nil?)
        flash[:warning] = 'Player not found.'
        return redirect_to(draft_players_url)
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
      return redirect_to(draft_players_url)
    end
  end

  def wanted
    if(@currentowner.draft_wanteds.count > 0)
      @batters = DraftBatter.byrankingvalue_and_wantedowner(@brv,@currentowner)
      @pitchers = DraftPitcher.byrankingvalue_and_wantedowner(@prv,@currentowner)

    end
  end

  def search
    @searchpage = true
    if(is_searchpage_request?)
      @returntouri = request.fullpath
    else
      @returntouri = (request.referer.blank?) ? request.fullpath : request.referer
    end
    ActiveRecord::Base::logger.debug "@returntouri = #{@returntouri}"
    if (!params[:q].nil? and !params[:q].empty? and params[:q].size >= 2)
      if(is_searchpage_request?)
        # no limit
        @playerlist = DraftPlayer.searchplayers(params[:q]).order(draftstatus: :asc).order(:last_name)
      else
        @playerlist = DraftPlayer.searchplayers(params[:q]).order(draftstatus: :asc).order(:last_name).limit(5)
      end
      if(!is_searchpage_request?)
        render(:layout => false)
      end
    end


  end

  def wantplayer
    @player = DraftPlayer.find(params[:id])
    if (@player.nil?)
      flash[:warning] = 'Player not found.'
    else
      @attributes = @player.statline.attributes.sort
      DraftWanted.create(:draft_player => @player, :owner => @currentowner, :notes => params[:notes], :highlight => params[:highlight])
      flash[:success] = 'Added to wanted players'
      SlackIt.post(message: "#{@currentowner.nickname} added a player to their wanted players list")
    end
    return redirect_to(draft_player_url(@player))
  end

  def removewant
    begin
      @player = DraftPlayer.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = 'Unable to find player.'
      return redirect_to(draft_root_url)
    end
    @wantaction = params[:want].nil? ? 'none' : params[:want]

    case @wantaction
    when 'no'
      @currentowner.wanted_draft_players.delete(@player)
      flash[:warning] = 'Removed from wanted players'
      SlackIt.post(message: "#{@currentowner.nickname} removed a player from their wanted players list")
    else
      # do nothing
    end
    return redirect_to(draft_player_url(@player))
  end


  def set_draft_owner_rank
    @player = DraftPlayer.find(params[:id])
    position = params[:position]
    position_attribute = (position != 'overall') ? "pos_#{position}" : position
    if(@player.nil?)
      returninformation = {'msg' => 'Invalid Player'}
      return render :json => returninformation.to_json, :status => 400
    elsif(!position or !DraftOwnerRank::RANKING_ATTRIBUTES.include?(position_attribute.to_sym) or !params[:draft_owner_rank][position_attribute])
      returninformation = {'msg' => 'Invalid Position'}
      return render :json => returninformation.to_json, :status => 400
    elsif(draft_owner_rank = @player.draft_owner_ranks.where(owner_id: @currentowner.id).first)
      draft_owner_rank.update_attribute(position_attribute, params[:draft_owner_rank][position_attribute])
      returninformation = {'msg' => 'OK!'}
      return render :json => returninformation.to_json, :status => 200
    elsif(draft_owner_rank = @player.draft_owner_ranks.create(owner_id: @currentowner.id,draft_player_id: @player.id,position_attribute => params[:draft_owner_rank][position_attribute]))
      returninformation = {'msg' => 'OK!'}
      return render :json => returninformation.to_json, :status => 200
    else
      returninformation = {'msg' => 'Unknown Error'}
      return render :json => returninformation.to_json, :status => 400
    end
  end

  def is_searchpage_request?
    !params[:searchpage].nil? and TRUE_VALUES.include?(params[:searchpage])
  end

  def is_experimental?
    !params[:experimental].nil? and TRUE_VALUES.include?(params[:experimental])
  end

end
