# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftOwnerRank < ApplicationRecord
  belongs_to :draft_player
  belongs_to :owner

  before_save :bounds_check_value

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

  def bounds_check_value
    RANKING_ATTRIBUTES.each do |rva|
      if(value = read_attribute(rva) and value <= 0 or value == 9999)
        write_attribute(rva,nil)
      end
    end
  end

end
