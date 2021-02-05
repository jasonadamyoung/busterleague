# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftBattingStatline < ApplicationRecord
  include CleanupTools

  has_one :draft_batter, :foreign_key => 'statline_id'

  RATINGFIELDS = {
    'c' => 'c',
    '1b' => 'first',
    '2b' => 'second',
    '3b' => 'third',
    'ss' => 'ss',
    'cf' => 'cf',
    'lf' => 'lf',
    'rf' => 'rf'
  }

  scope :fieldergroup, lambda {|position|
    ratingfield = RATINGFIELDS[position]
    if(position == 'of')
      conditionstring = "(position IN ('cf','lf','rf') or cf != '' or lf != '' or rf != '')"
    else
      conditionstring = "(position = '#{position}' or #{ratingfield} != '')"
    end
    {:conditions => conditionstring}
  }

  def self.rebuild_from_real_stats_for_season(season)
    self.dump_data
    RealBattingStat.for_season(season).each do |rbs|
      self.create(rbs.attributes.reject{|key,value| ["id"].include?(key) })
    end
  end

end
