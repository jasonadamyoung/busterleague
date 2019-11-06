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

end