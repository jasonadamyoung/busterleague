# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class RealBattingStat < ApplicationRecord
  include RealStatTools
  include CleanupTools

  belongs_to :roster, optional: true
  belongs_to :player, optional: true
  belongs_to :team, optional: true

  scope :for_season, lambda {|season| where(season: season)}


  def name
    "#{self.first_name} #{self.last_name}"
  end

end
