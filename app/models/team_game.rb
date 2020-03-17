# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TeamGame < ApplicationRecord
  extend CleanupTools

  belongs_to :game
  has_one :boxscore, :through => :game
  belongs_to :team
  belongs_to :opponent, :class_name => 'Team'
  has_many :innings, :through => :boxscore

  scope :wins, -> { where(:win => true) }
  scope :losses, -> { where(:win => false) }
  scope :home, -> { where(:home => true) }
  scope :away, -> { where(:home => false) }
  scope :for_season, lambda {|season| where(season: season)}
  scope :through_date, lambda {|date| where("date <= ?",date)}
  scope :zero_hits, -> { where(:hits => 0) }
  scope :zero_errors, -> { where(:errs => 0) }
  scope :opponent_zero_hits, -> { where(:opponent_hits => 0) }
  scope :opponent_zero_errors, -> { where(:opponent_errs => 0) }
  scope :no_hitters, -> { wins.opponent_zero_hits }
  scope :perfects, -> { wins.opponent_zero_hits.zero_errors }

  def self.through_season_date(season,date)
    if(season == 'all' or season == 0)
      through_date(date)
    else
      for_season(season).through_date(date)
    end
  end

  def self.earliest_date(season)
    if(season == 'all' or season == 0)
      self.minimum(:date)
    else
      self.where(season: season).minimum(:date)
    end
  end

  def self.latest_date(season)
    if(season == 'all' or season == 0)
      self.maximum(:date)
    else
      self.where(season: season).maximum(:date)
    end
  end

  def score
    [runs,opponent_runs]
  end

end
