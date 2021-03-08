# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module PlayersHelper


  def player_link(player)
    link_to(player.fullname, player).html_safe
  end

  def player_season_link(player, season)
    link_to(player.fullname,player_path(player,season: season)).html_safe
  end

  def display_ip(ip)
    (integer,decimal) = ip.divmod(1)
    "#{integer}.#{number_with_precision((decimal*3),precision: 0)}"
  end

  def ops_display(player,hand)
    displaytext = ''
    if(hand == 'left')
      htmloptions = {:title => "At-Bats vs. Left #{player.statline.l_pa}", :rel => 'tooltip'}
      if(!player.statline.l_pa.nil?)
        htmloptions.merge!(:class => 'label label-warning') if (player.statline.l_pa < 75)
      end
      link_to(player.statline.l_ops, '#', htmloptions).html_safe
    else
      link_to(player.statline.r_ops, '#', :title => "At-Bats vs. Right #{player.statline.r_pa}", :rel => 'tooltip').html_safe
    end
  end

  def display_stat(stat_object,stat_name)
    if(stat = stat_object.send(stat_name))
      if(stat_name == 'ip')
        display_ip(stat)
      elsif(stat.is_a?(Float))
        if(!precision = DefinedStat::PRECISIONS[stat_name])
          precision = 1
        end
        number_with_precision(stat,precision: precision)
      else
        number_with_precision(stat,precision: 0)
      end
    else
      '-'
    end
  end

end