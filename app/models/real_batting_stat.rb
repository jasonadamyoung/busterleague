# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class RealBattingStat < ApplicationRecord
  extend StatTools
  extend CleanupTools

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team, optional: true

  scope :for_season, lambda {|season| where(season: season)}


  def name
    "#{self.first_name} #{self.last_name}"
  end

end
