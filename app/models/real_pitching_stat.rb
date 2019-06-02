# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class RealPitchingStat < ApplicationRecord
  extend StatTools
  extend CleanupTools

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team, optional: true

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def ip=(ip)
    (integer,decimal) = ip.divmod(1)
    write_attribute(:ip, (integer+ ((decimal*10) / 3.to_f)))
  end
end