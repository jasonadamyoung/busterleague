# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftBattingStatline < ApplicationRecord
  include CleanupTools

  has_one :draft_batter, :foreign_key => 'statline_id'

  RATINGFIELDS = {
    'c' => 'pos_c',
    '1b' => 'pos_1b',
    '2b' => 'pos_2b',
    '3b' => 'pos_3b',
    'ss' => 'pos_ss',
    'cf' => 'pos_cf',
    'lf' => 'pos_lf',
    'rf' => 'pos_rf'
  }

  scope :fieldergroup, lambda {|position|
    if(position == 'dh')
      conditionstring = "(position = '#{position}')"
    elsif(position == 'of')
      conditionstring = "(position IN ('cf','lf','rf') or cf != '' or lf != '' or rf != '')"
    else
      ratingfield = RATINGFIELDS[position]
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


  def throws
    bats
  end

end
