# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftOwnerPositionPref < ApplicationRecord
  belongs_to :owner
  belongs_to :prefable, polymorphic: true

  before_save :set_player_type

  # player types
  PITCHER = 1
  BATTER = 2

  # positions
  PITCHING_POSITIONS = ['sp','rp']
  BATTING_POSITIONS = ['c','1b','2b','3b','ss','lf','cf','rf','dh']

  # allowed prefables
  ALLOWED_PREFABLES = ['DraftRankingValue',"DraftStatPreference"]

  scope :pitching, -> { where(player_type: PITCHER) }
  scope :batting, -> { where(player_type: BATTER) }

  def self.position_list(playertype)
    returnpositions = []
    case playertype
    when PITCHER
      returnpositions += PITCHING_POSITIONS
    when BATTER
      returnpositions += BATTING_POSITIONS
    else
      returnpositions += PITCHING_POSITIONS + BATTING_POSITIONS
    end
    returnpositions
  end

  def set_player_type
    self.player_type = self.prefable.playertype
  end

end
