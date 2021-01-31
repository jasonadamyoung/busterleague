# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPitchingStatline < ApplicationRecord
  extend CleanupTools

  has_one :draft_pitcher, :foreign_key => 'statline_id'
end