# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPitcher < DraftPlayer
  belongs_to :statline, :class_name => 'DraftPitchingStatline'
  paginates_per 50

  POSITIONS = {
    'sp' => 'Starters',
    'rp' => 'Relievers'
  }

  scope :starters, lambda { where(:position => 'SP') }
  scope :relievers, lambda { where(:position => 'RP') }

  scope :byrankingvalue, lambda {|rv|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue").joins(:draft_rankings).where("draft_rankings.draft_ranking_value_id = #{rv.id}").order("rankvalue DESC").order("#{self.table_name}.id ASC")
  }

  scope :byrankingvalue_and_wantedowner, lambda {|rv,owner|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue,draft_wanteds.notes as notes,draft_wanteds.highlight as highlight")
    .joins([:draft_rankings,:wantedowners])
    .where("draft_rankings.draft_ranking_value_id = #{rv.id} and owners.id = #{owner.id}")
    .order("rankvalue DESC").order("#{self.table_name}.id ASC")
  }

end
