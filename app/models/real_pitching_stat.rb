# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class RealPitchingStat < ApplicationRecord

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team

end