# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftWanted < ApplicationRecord
  belongs_to :player
  belongs_to :owner
end
