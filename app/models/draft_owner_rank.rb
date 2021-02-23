# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftOwnerRank < ApplicationRecord
  belongs_to :draft_player
  belongs_to :owner

  DEFAULT_RANK = 9999

  # status flags
  NOT_USED = 0
  OVERALL_RANK = 1
  POSITION_RANK = 2

  RANKING_ATTRIBUTES = [
    :overall,
    :pos_sp,
    :pos_rp,
    :pos_c,
    :pos_1b,
    :pos_2b,
    :pos_3b,
    :pos_ss,
    :pos_lf,
    :pos_cf,
    :pos_rf,
    :pos_dh
  ]

  def set_attribute(attribute,value)
    if(value.to_i == 0)
      write_attribute(attribute,DEFAULT_RANK)
    else
      write_attribute(attribute,value.to_i)
    end
  end

  def get_attribute(attribute)
    value = read_attribute(attribute)
    (value == DEFAULT_RANK) ? 0 : value
  end

  RANKING_ATTRIBUTES.each do |attribute|
    define_method(attribute) { get_attribute(attribute) }
    define_method("#{attribute}=".to_sym) do |value|
      set_attribute(attribute,value)
    end
  end

  def self.valid_dor(draft_owner_rank)
    [NOT_USED,OVERALL_RANK,POSITION_RANK].include?(draft_owner_rank)
  end


end
