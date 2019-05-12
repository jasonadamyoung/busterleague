# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module PlayersHelper


  def player_link(player)
    "#{player.fullname}".html_safe
    # link_to(player.fullname, player).html_safe
  end

end