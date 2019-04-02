# encoding: utf-8

# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module BoxscoresHelper

  def boxscore_title(boxscore)
    "#{boxscore.home_team.abbrev} vs. #{boxscore.away_team.abbrev} - #{boxscore.date.strftime("%b %d")}"
  end
  
end