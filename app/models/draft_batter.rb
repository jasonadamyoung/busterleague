# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftBatter < DraftPlayer
  belongs_to :statline, :class_name => 'DraftBattingStatline'
  paginates_per 50

  POSITIONS = {
    'c' => 'Catchers',
    '1b' => 'First Basemen',
    '2b' => 'Second Basemen',
    '3b' => 'Third Basemen',
    'ss' => 'Shortstops',
    'cf' => 'Center Fielders',
    'lf' => 'Left Fielders',
    'rf' => 'Right Fielders'
  }

  scope :fieldergroup, lambda {|position|
    ratingfield = DraftBattingStatline::RATINGFIELDS[position]
    if(position == 'of')
      conditionstring = "(players.position IN ('cf','lf','rf') or draft_batting_statlines.cf != '' or draft_batting_statlines.lf != '' or draft_batting_statlines.rf != '')"
    else
      conditionstring = "(players.position = '#{position}' or draft_batting_statlines.#{ratingfield} != '')"
    end
    joins(:statline).where(conditionstring)
  }

  scope :byrankingvalue, lambda {|rv|
    select("#{self.table_name}.*, rankings.value as rankvalue").joins(:rankings).where("rankings.ranking_value_id = #{rv.id}").order("rankvalue DESC")
  }

  scope :byrankingvalue_and_wantedowner, lambda {|rv,owner|
    select("#{self.table_name}.*, rankings.value as rankvalue, wanteds.notes as notes, wanteds.highlight as highlight")
    .joins([:rankings,:wantedowners])
    .where("rankings.ranking_value_id = #{rv.id} and owners.id = #{owner.id}")
    .order("rankvalue DESC")
  }

end
