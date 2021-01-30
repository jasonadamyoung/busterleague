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
    link_to("#{attributename}",'#', :onclick => "$('#stat_preference_column_list').tokenInput('add',{id: \'#{attributename}\', name:\'#{attributename}\'})").html_safe
  end
end
