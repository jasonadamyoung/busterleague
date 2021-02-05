# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class PitcherPlayingTime < ApplicationRecord
  include CleanupTools

  belongs_to :roster

  def need_ip
    need_ip = (self.qualifying_ip - self.ip)
    (need_ip >= 0) ? (need_ip) : 0
  end

end