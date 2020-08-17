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

  scope :upcoming, lambda {|limit=5|
    if(DraftPick.current_pick)
      currentpick = DraftPick.current_pick.overallpick
    else
      currentpick = DraftPick.last.overallpick+1
    end
    where(["overallpick BETWEEN #{currentpick} AND #{currentpick + limit - 1}"])
  }

  scope :recent, lambda {|limit=5|
    if(DraftPick.current_pick)
      currentpick = DraftPick.current_pick.overallpick
    else
      currentpick = DraftPick.last.overallpick+1
    end
    where(["overallpick BETWEEN #{currentpick - limit} AND #{currentpick - 1}"])
  }


  # pick codes
  CURRENTPICK = -1
  NOPICK = 0

  def self.next_human_pick
    currentpick = DraftPick.current_pick.overallpick
    joins(:team).where("teams.owner_id != #{Owner.computer_id}").where("overallpick >= #{currentpick}").first
  end

  def self.current_pick
    maxpick = DraftPick.where('player_id != 0').maximum(:overallpick)
    maxpick = maxpick.nil? ? 1 : maxpick+1
    DraftPick.where('overallpick = ?',maxpick).first
  end

  def self.trade(from_team,from_round,to_team,to_round)
    dp = DraftPick.where(overallpick: from_team.draftpos + ((from_round-1) * 20)).first
    if(!dp.nil?)
      dp.original_team_id = dp.team_id
      dp.traded = true
      dp.team = to_team
      dp.save
    end

    dp = DraftPick.where(overallpick: to_team.draftpos + ((to_round-1) * 20)).first
    if(!dp.nil?)
      dp.original_team_id = dp.team_id
      dp.traded = true
      dp.team = from_team
      dp.save
    end
  end


end
