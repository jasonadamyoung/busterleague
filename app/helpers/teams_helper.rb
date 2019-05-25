# encoding: utf-8

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
      wins = wl[:wins]
      losses = wl[:losses]
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


  def team_link(team)
    link_to(team.name, team).html_safe
  end

  def team_season_link(team,season)
    link_to(team.name, team_path(team,season: season)).html_safe
  end


end
