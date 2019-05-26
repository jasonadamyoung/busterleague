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

end