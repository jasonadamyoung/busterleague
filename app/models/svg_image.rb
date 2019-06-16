# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class SvgImage < ApplicationRecord
  belongs_to :logoable, polymorphic: true

end