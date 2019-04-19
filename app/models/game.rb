# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Game < ApplicationRecord
  belongs_to :boxscore
  belongs_to :team
  belongs_to :opponent, :class_name => 'Team'
  has_many :innings, :through => :boxscores
  
  scope :wins, -> { where(:win => true) }
  scope :losses, -> { where(:win => false) }
  scope :home, -> { where(:home => true) }
  scope :away, -> { where(:home => false) }
  scope :for_season, lambda {|season| where(season: season)}
  scope :through_season_date, lambda {|season,date| where(season: season).where("date <= ?",date)}
  scope :zero_hits, -> { where(:hits => 0) }
  scope :zero_errors, -> { where(:errs => 0) }
  scope :opponent_zero_hits, -> { where(:opponent_hits => 0) }
  scope :opponent_zero_errors, -> { where(:opponent_errs => 0) }
  scope :no_hitters, -> { wins.opponent_zero_hits }
  scope :perfects, -> { wins.opponent_zero_hits.zero_errors }


  ALLOWED_SEASONS = 1999..2018

  def self.current_season
    Date.today.year - 1
  end

  def self.allowed_seasons
    ALLOWED_SEASONS.to_a
  end

  def self.available_seasons
    (self.distinct.pluck(:season) + [self.current_season]).uniq.sort.reverse
  end

  def self.earliest_date(season)
    self.where(season: season).minimum(:date)
  end

  def self.latest_date(season)
    self.where(season: season).maximum(:date)
  end

  def self.rebuild_all
    self.connection.execute("TRUNCATE table #{table_name};")
    Boxscore.find_each do |boxscore|
      boxscore.create_games
    end
  end

  def score
    [runs,opponent_runs]
  end

end
