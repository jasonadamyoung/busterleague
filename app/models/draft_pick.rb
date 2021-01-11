# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPick < ApplicationRecord
  belongs_to :team
  belongs_to :original_team, :class_name => 'Team', optional: true
  belongs_to :player, optional: true
  has_one :owner, :through => :team
  paginates_per Team.count

  scope :for_season, lambda {|season| where(season: season)}

  scope :upcoming_for_season, lambda {|season,limit=5|
    if(DraftPick.for_season(season).current_pick_for_season(season))
      currentpick = DraftPick.for_season(season).current_pick_for_season(season).overallpick
    else
      currentpick = DraftPick.for_season(season).last.overallpick+1
    end
    for_season(season).where(["overallpick BETWEEN #{currentpick} AND #{currentpick + limit - 1}"])
  }

  scope :recent_for_season, lambda {|season,limit=5|
    if(DraftPick.current_pick_for_season(season))
      currentpick = DraftPick.current_pick_for_season(season).overallpick
    else
      currentpick = DraftPick.for_season(season).last.overallpick+1
    end
    for_season(season).where(["overallpick BETWEEN #{currentpick - limit} AND #{currentpick - 1}"])
  }

  # pick codes
  CURRENTPICK = -1
  NOPICK = 0

  def self.next_human_pick_for_season(season)
    currentpick = DraftPick.for_season(season).current_pick.overallpick
    joins(:team).for_season(season).where("teams.owner_id != #{Owner.computer_id}").where("overallpick >= #{currentpick}").first
  end

  def self.current_pick_for_season(season)
    maxpick = DraftPick.for_season(season).where('player_id != 0').maximum(:overallpick)
    maxpick = maxpick.nil? ? 1 : maxpick+1
    DraftPick.for_season(season).where('overallpick = ?',maxpick).first
  end

  def self.trade(season,from_team,from_round,to_team,to_round)
    dp = DraftPick.for_season(season).where(overallpick: from_team.draftpos + ((from_round-1) * 20)).first
    if(!dp.nil?)
      dp.original_team_id = dp.team_id
      dp.traded = true
      dp.team = to_team
      dp.save
    end

    dp = DraftPick.for_season(season).where(overallpick: to_team.draftpos + ((to_round-1) * 20)).first
    if(!dp.nil?)
      dp.original_team_id = dp.team_id
      dp.traded = true
      dp.team = from_team
      dp.save
    end
  end


end
