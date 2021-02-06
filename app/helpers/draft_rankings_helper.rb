module DraftRankingsHelper

  def add_ranking_attribute_link(playertype,attributename)
    link_to("#{attributename} #{directional_arrow(playertype,attributename)}",'#', :onclick => "$('#rankingattributes').append('#{escape_javascript(render(:partial => 'ranking_attribute',:locals => {:attributename => attributename}))}')").html_safe
  end

  def ops_display(player,hand)
    displaytext = ''
    if(hand == 'left')
      htmloptions = {:title => "At-Bats vs. Left #{player.statline.lpa}", :rel => 'tooltip'}
      if(!player.statline.lpa.nil?)
        htmloptions.merge!(:class => 'label label-warning') if (player.statline.lpa < 75)
      end
      link_to(player.statline.lops, '#', htmloptions).html_safe
    else
      link_to(player.statline.rops, '#', :title => "At-Bats vs. Right #{player.statline.rpa}", :rel => 'tooltip').html_safe
    end
  end

  def ranking_values_for_chart(ranking_value)
    if ranking_value.playertype == RankingValue::PITCHER
      Pitcher.rankingvalues(ranking_value)
    else
      Batter.rankingvalues(ranking_value)
    end
  end

  def chart_unique_id(base,compare)
    "b#{base.id}_c#{compare.id}"
  end

end
