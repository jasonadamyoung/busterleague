# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DefinedStat < ApplicationRecord

  scope :batting, ->{where(player_type: DefinedStat::BATTING)}
  scope :pitching, ->{where(player_type: DefinedStat::PITCHING)}

  scope :core, ->{where(category_code: DefinedStat::CORE)}

  # player type
  PITCHING= 1
  BATTING = 2

  # sorts
  ASCENDING = 1
  DESCENDING = -1

  # category code
  UNDEFINED = 0
  CORE = 1
  SECONDARY = 2

  # STAT_CODE
  FACT = 1
  CALCULATED = 2

  PRECISIONS = {
    "avg" => 3,
    "obp" => 3,
    "spc" => 3,
    "ops" => 3,
    'iso' => 3,
    'tavg' => 3,
    'sec' => 3,   
    "era" => 2,
    "whip" => 2,
    "rcera" => 2,
    "cera" => 2
  }


end

