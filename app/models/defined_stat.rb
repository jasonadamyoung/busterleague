# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DefinedStat < ApplicationRecord

  scope :batting, ->{where(player_type: DefinedStat::BATTER)}
  scope :pitching, ->{where(player_type: DefinedStat::PITCHER)}

  scope :core, ->{where(category_code: DefinedStat::CORE)}

  scope :batting_statlines, ->{batting.where(name: (RealBattingStat.column_names - ["id"]))}
  scope :pitching_statlines, ->{pitching.where(name: (RealPitchingStat.column_names - ["id"]))}

  scope :draft_batting_statlines, ->{batting.where(name: (DraftBattingStatline.column_names - ["id"]))}
  scope :draft_pitching_statlines, ->{pitching.where(name: (DraftPitchingStatline.column_names - ["id"]))}


  # player type
  PITCHER= 1
  BATTER = 2

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
    "l_avg" => 3,
    "r_avg" => 3,
    "obp" => 3,
    "l_obp" => 3,
    "r_obp" => 3,
    "spc" => 3,
    "l_spc" => 3,
    "r_spc" => 3,
    "ops" => 3,
    "l_ops" => 3,
    "r_ops" => 3,
    'iso' => 3,
    'tavg' => 3,
    'sec' => 3,
    "era" => 2,
    "whip" => 2,
    "rcera" => 2,
    "cera" => 2,
    "babip" => 3,
    "woba" => 3
  }

  PA_ELIGIBLE_ONLY = ['avg','obp','spc','ops','k','tavg','sec','rc27','iso']
  IP_ELIGIBLE_ONLY = ['era','bb_per_9','h_per_9','r_per_9','k_per_9','hr_per_9']


  def self.draft_columns(player_type)
    corelist = []
    if(player_type == BATTER)
      corelist += ['ab','ops','l_ops','r_ops','opsplus','war_fg','war_br']
      otherlist = self.draft_batting_statlines.pluck(:name) - corelist
    else
      corelist += ['w','s','era','whip','fip']
      corelist += ['xfip','war_fg','war_br','eraplus','hr_per_9','k_per_9','bb_per_9','l_ops','r_ops','ops']
      otherlist = self.draft_pitching_statlines.pluck(:name) - corelist
    end
    corelist + otherlist
  end

  def leader_order
    # pick the opposite direction to get the "top ten"
    sd = (sort_direction == ASCENDING) ? 'DESC' : 'ASC'
    "#{name} #{sd}"
  end

  def leaders_for_season(season,limit)
    case player_type
    when BATTING
      if(PA_ELIGIBLE_ONLY.include?(self.name))
        BattingStat.players.for_season(season).totals.pa_eligible.order(leader_order).limit(limit)
      else
        BattingStat.players.for_season(season).totals.order(leader_order).limit(limit)
      end
    when PITCHING
      if(PA_ELIGIBLE_ONLY.include?(self.name))
        PitchingStat.players.for_season(season).totals.ip_eligible.order(leader_order).limit(limit)
      else
        PitchingStat.players.for_season(season).totals.order(leader_order).limit(limit)
      end
    else
      nil
    end
  end

end
