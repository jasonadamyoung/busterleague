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
    'rf' => 'Right Fielders',
    'dh' => 'Designated Hitters'
  }

  scope :fieldergroup, lambda {|position|
    if(position == 'dh')
      conditionstring = "(draft_players.position = '#{position}')"
    elsif(position == 'of')
      conditionstring = "(draft_players.position IN ('cf','lf','rf') or draft_batting_statlines.pos_cf != '' or draft_batting_statlines.pos_lf != '' or draft_batting_statlines.pos_rf != '')"
    else
      ratingfield = DraftBattingStatline::RATINGFIELDS[position]
      conditionstring = "(draft_players.position = '#{position}' or draft_batting_statlines.#{ratingfield} != '')"
    end
    joins(:statline).where(conditionstring)
  }

  scope :byrankingvalue, lambda {|rv|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue").joins(:draft_rankings).where("draft_rankings.draft_ranking_value_id = #{rv.id}").order("rankvalue DESC")
  }

  scope :byrankingvalue_and_wantedowner, lambda {|rv,owner|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue,draft_wanteds.notes as notes,draft_wanteds.highlight as highlight")
    .joins([:draft_rankings,:wantedowners])
    .where("draft_rankings.draft_ranking_value_id = #{rv.id} and owners.id = #{owner.id}")
    .order("rankvalue DESC")
  }

end
