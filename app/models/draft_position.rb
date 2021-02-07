# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPosition < ApplicationRecord
  include CleanupTools

  belongs_to :team


end
