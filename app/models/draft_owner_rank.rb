# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftOwnerRank < ApplicationRecord
  belongs_to :draft_player
  belongs_to :owner

  DEFAULT_RANK = 9999

  # override overall to change '0' to DEFAULT_RANK
  def overall=(value)
    if(value == 0)
      write_attribute(:overall,DEFAULT_RANK)
    else
      write_attribute(:overall,value)
    end
  end

  def overall
    value = read_attribute(:overall)
    (value == DEFAULT_RANK) ? 0 : value
  end

end
