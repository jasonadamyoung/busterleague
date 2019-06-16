# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module TeamsHelper

  def display_gb(gb)
    if(gb == 0.0)
      '-'
    elsif((gb - 0.5) == gb.to_i)
      "#{gb.to_i} ½"
    else
      "#{gb.to_i}"
    end
  end

  def display_wl(wl)
    if(wl.is_a?(Array))
      (wins,losses) = wl
    elsif(wl.is_a?(Hash))
      wins = wl['wins']
      losses = wl['losses']
    else
      wins = 'unknown'
      losses = 'unknown'
    end
    "#{wins} - #{losses}"
  end

  def display_score(score)
    (a_runs,b_runs) = score
    "#{a_runs} - #{b_runs}"
  end


  def game_link(game)
    if(game.season != 1999)
      link_to(game.date.strftime("%b %d"), boxscore_path(game.boxscore)).html_safe
    else
      game.date.strftime("%b %d").html_safe
    end
  end

  def team_link(team)
    link_to(team.name, team).html_safe
  end

  def team_season_link(team,season)
    link_to(team.name, team_path(team,season: season)).html_safe
  end

  def owner_icon(team_season)
    if(team_season.human_owned?)
      '<i class="fas fa-user text-muted"></i>'.html_safe
    else
      '<i class="fas fa-laptop text-muted"></i>'.html_safe
    end
  end

  def ws_win_icon
    '<i class="fas fa-trophy text-warning"></i>'.html_safe
  end

  def lcs_win_icon
    '<i class="fas fa-medal text-secondary"></i>'.html_safe
  end


end
