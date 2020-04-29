# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamSeason < ApplicationRecord

  belongs_to :team

  scope :human, lambda { where("owner_id <> #{Owner.computer_id}")}
  scope :computer, lambda { where("owner_id = #{Owner.computer_id}")}

  scope :american, lambda { where(:league => 'American')}
  scope :national, lambda { where(:league => 'National')}
  scope :east, lambda { where(:division => 'East')}
  scope :west, lambda { where(:division => 'West')}

  scope :for_season, lambda {|season| where(season: season)}
  scope :division_winners, ->{where(div_win: true)}

  def human_owned?
    (self.owner_id != Owner.computer_id)
  end

  def self.create_for_season_and_team(season,team)
    ts = self.new(season: season,
                  team: team,
                  abbrev: team.abbrev,
                  owner_id: team.owner_id,
                  league: team.league,
                  division: team.division,
                  web_team_id: team.web_team_id)
    ts.save!
  end

end