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

  scope :byrankingvalue, lambda {|rv|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue").joins(:draft_rankings).where("draft_rankings.draft_ranking_value_id = #{rv.id}").order("rankvalue DESC,#{self.table_name}.id ASC").order("#{self.table_name}.id ASC")
  }

  scope :byrankingvalue_and_wantedowner, lambda {|rv,owner|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue,draft_wanteds.notes as notes,draft_wanteds.highlight as highlight")
    .joins([:draft_rankings,:wantedowners])
    .where("draft_rankings.draft_ranking_value_id = #{rv.id} and owners.id = #{owner.id}")
    .order("rankvalue DESC").order("#{self.table_name}.id ASC")
  }

  def eligible_positions
    return_positions = []
    DraftBattingStatline::RATINGFIELDS.each do |pos,rating_field|
      if(has_rating = self.statline.send(rating_field))
        return_positions << pos
      end
    end
    return_positions << self.position
    return_positions << 'dh'
    return_positions.uniq
  end

end
