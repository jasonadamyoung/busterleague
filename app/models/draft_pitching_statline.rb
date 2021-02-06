# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPitchingStatline < ApplicationRecord
  include CleanupTools

  has_one :draft_pitcher, :foreign_key => 'statline_id'

  def self.rebuild_from_real_stats_for_season(season)
    self.dump_data
    RealPitchingStat.for_season(season).each do |rbs|
      self.create(rbs.attributes.reject{|key,value| ["id"].include?(key) })
    end
  end

end