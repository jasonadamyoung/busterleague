# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPitchingStatline < ApplicationRecord
  has_one :pitcher, :foreign_key => 'statline_id'
end