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
  
end
