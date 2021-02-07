# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module DraftHelper

  def display_position_counts(array)
    returntext = '<table class="table">'
    returntext += '<tbody>'


    ['SP','RP'].each do |position|
      returntext += "<tr><td>#{position.upcase}</td><td>#{count_display(array[position])}</td></tr>"
    end

    DraftBattingStatline::RATINGFIELDS.keys.each do |position|
      returntext += "<tr><td>#{position.upcase}</td><td>#{count_display(array[position])}</td></tr>"
    end
    other = array['dh'] ? array['dh'] : 0
    other += array[''] ? array[''] : 0
    returntext += "<tr><td>other</td><td>#{count_display(other)}</td></tr>"
    returntext += '</tbody>'
    returntext += '</table>'
    returntext.html_safe
  end

  def count_display(count)
    if(count.blank? or count == 0)
      "<span class='badge'>0</span>"
    else
      "<span class='badge badge-info'>#{count}</span>"
    end
  end

  def player_count_display(count,required_count)
    if(count.blank? or count == 0)
      "<span class='badge badge-danger'>#{required_count - count}</span>"
    elsif(count < required_count)
      "<span class='badge badge-warning'>#{required_count - count}</span>"
    elsif(count == required_count)
      "<span class='badge badge-success'>#{required_count - count}</span>"
    elsif(count > required_count)
      "<span class='badge badge-danger'>#{required_count - count}</span>"
    end
  end

  def add_statdisplay_attribute_link(attributename)
    addhash = {'id' => attributename, 'name' => attributename}
    link_to("#{attributename}",'#', :onclick => "$('#draft_stat_preference_column_list').tokenInput('add',{id: \'#{attributename}\', name:\'#{attributename}\'})").html_safe
  end

  def playerwantlink(player,domcontainer,confirm=nil)
    if(@currentowner.wanted_draft_players.include?(player))
      wantaction = 'no'
      linklabel = '<i class="fa fa-minus white"></i> Remove from Wanted'.html_safe
      titleattribute = 'Remove this player from the list of your wanted players'
      htmloptions = {:method => :post, :title => titleattribute, :class=> 'btn btn-primary btn-small'}
      htmloptions.merge!({:confirm => confirm}) if(!confirm.nil?)
      return link_to(linklabel,removewant_draft_player_path(id: player.id, domcontainer: domcontainer, want: wantaction),htmloptions).html_safe
    elsif(player.teamed?)
      return ''
    else
      return link_to('<i class="fa fa-plus white"></i> Add to Wanted'.html_safe, '#', :id => 'playerwantadd', :class => 'btn btn-primary btn-small').html_safe
    end
  end

  def playerteamlink(player)
    if(player.team.nil?)
      'n/a'
    else
      draft_team_link(player.team)
    end
  end

  def draft_team_link(team)
    link_to(team.name, draft_team_path(team)).html_safe
  end

  def humane_date(time)
     time.strftime("%B %e, %Y, %l:%M %p")
  end

  def position_to_rating_field(position)
    if(position != 'dh')
      DraftBattingStatline::RATINGFIELDS[position]
    end
  end

  def position_check(fielder,rating_field)
    if(DraftBattingStatline::RATINGFIELDS[fielder.position] == rating_field)
      raw("<strong>#{fielder.statline.send(rating_field)}</strong>")
    else
      fielder.statline.send(rating_field)
    end
  end


  def rankingvalue_items(rvtype)
    case rvtype
    when 'prv'
      playertype = DraftRankingValue::PITCHER
    when 'brv'
      playertype = DraftRankingValue::BATTER
    else
      return ''
    end
    computer_ranks = Owner.computer.draft_ranking_values.where(:playertype => playertype)
    owner_ranks = @currentowner.draft_ranking_values.where(:playertype => playertype)
    nav_items = []
    (owner_ranks + computer_ranks).each do |rankingvalue|
      nav_items << rv_nav_item(rankingvalue)
    end
    nav_items << rv_nav_item('new',rvtype)
    nav_items.join("\n").html_safe
  end

  def rv_nav_item(rankingvalue,rvtype_if_new=nil)
    get_params = {}
    get_params[:currenturi] = Base64.encode64(request.fullpath)
    if(rankingvalue == 'new')
      get_params[rvtype_if_new] = 'new'
      list_item_class = ''
      label = 'new...'
    elsif(rankingvalue.playertype == DraftRankingValue::PITCHER)
      get_params[:prv] = rankingvalue.id
      label = rankingvalue.label
    else
      get_params[:brv] = rankingvalue.id
      label = rankingvalue.label
    end
    link_to(label,setrv_draft_ranking_values_path(get_params),class: 'dropdown-item').html_safe
  end

  def draftstatus_label(status)
    case status
    when DraftPlayer::ALL_PLAYERS
      'All'
    when DraftPlayer::DRAFTED_PLAYERS
      'Rostered'
    when DraftPlayer::NOTDRAFTED_PLAYERS
      'Available'
    when DraftPlayer::ME_ME_ME
      'Available+Yours'
    end
  end

  def draftstatus_nav_item(status)
    get_params = {}
    if(request.fullpath =~ %r{players})
      get_params[:currenturi] = Base64.encode64(request.fullpath)
    else
      get_params[:currenturi] = Base64.encode64(position_players_url(position: 'all'))
    end
    get_params[:draftstatus] = status
    label = draftstatus_label(status)
    link_to(label,setdraftstatus_draft_players_path(get_params),class: 'dropdown-item').html_safe
  end


  def draftstatus_options
    option_ranks = []
    option_ranks << ["All",DraftPlayer::ALL]
    option_ranks << ["Rostered",DraftPlayer::DRAFTED]
    option_ranks << ["Available",DraftPlayer::NOTDRAFTED]
    option_ranks << ["Available+Yours",DraftPlayer::ME_ME_ME]
    return option_ranks
  end

  def display_rankvalue(rankvalue)
    number_with_precision(rankvalue*100,precision: 1)
  end

  def directional_arrow(playertype,attribute)
    if(definedstat = DefinedStat.where(player_type: playertype, name: attribute).first)
      direction = definedstat.sort_direction
    else
      direction = 0
    end

    if(direction > 0)
      '↑'
    elsif(direction < 0)
      '↓'
    else
      '⭤'
    end
  end

  def importance_label(importance)
    case importance
    when 1
      '(high)'
    when 2
      '(medium)'
    when 3
      '(low)'
    end
  end

  def player_id_link(player_id)
    player = DraftPlayer.where(id: player_id).first
    if(player)
      link_to("#{player.fullname}", draft_player_url(player), :class => 'label label-info').html_safe
    end
  end


  def statdisplay_items(display_type)
    case display_type
    when 'psp'
      playertype = DraftStatPreference::PITCHER
    when 'bsp'
      playertype = DraftStatPreference::BATTER
    else
      return ''
    end
    computer = Owner.computer.draft_stat_preferences.where(:playertype => playertype)
    owner = @currentowner.draft_stat_preferences.where(:playertype => playertype)
    nav_items = []
    (computer + owner).each do |sp|
      nav_items << sp_nav_item(sp)
    end
    nav_items << sp_nav_item('new',display_type)
    nav_items.join("\n").html_safe
  end

  def sp_nav_item(stat_preference,sptype_if_new=nil)
    get_params = {}
    get_params[:currenturi] = Base64.encode64(request.fullpath)
    if(stat_preference == 'new')
      get_params[sptype_if_new] = 'new'
      list_item_class = ''
      label = 'new...'
    elsif(stat_preference.playertype == DraftStatPreference::PITCHER)
      get_params[:psp] = stat_preference.id
      label = stat_preference.label
    else
      get_params[:bsp] = stat_preference.id
      label = stat_preference.label
    end
    link_to(label,setsp_draft_stat_preferences_path(get_params),class: 'dropdown-item').html_safe
  end


  def draft_team_nav_dropdown_item(team)
    path = draft_team_path(team)
    nav_dropdown_item(path,team.name)
  end


end
