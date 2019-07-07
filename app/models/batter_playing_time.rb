# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class BatterPlayingTime < ApplicationRecord

  belongs_to :roster

  def remaining_starts
    self.allowed_starts - self.gs
  end

  def need_ab
    need_ab = (self.qualifying_ab - self.ab)
    (need_ab >= 0) ? (need_ab) : 0
  end
  
end