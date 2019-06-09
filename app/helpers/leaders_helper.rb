# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module LeadersHelper

  def display_leader_label(defined_stat)
    if(!label = defined_stat.display_label)
      label = defined_stat.name
    end
    label.html_safe
  end

  def display_leader_team(stat_object)
    if(stat_object.team_id == 0)
      "(mult)"
    else
      link_to(stat_object.team.abbrev, team_path(stat_object.team,season: stat_object.season)).html_safe
    end
  end

  
end
