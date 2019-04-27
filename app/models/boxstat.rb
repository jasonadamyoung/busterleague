# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Boxstat < ApplicationRecord
  belongs_to :boxscore

  def home_innings
    self.home_team["innings"]
  end

  def away_innings
    self.away_team["innings"]
  end

end