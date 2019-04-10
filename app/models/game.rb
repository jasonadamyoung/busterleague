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

  ALLOWED_SEASONS = 1999..2018

  def self.current_season
    Date.today.year - 1
  end

  def self.allowed_seasons
    ALLOWED_SEASONS.to_a
  end   

  def self.earliest_date(season)
    self.where(season: season).minimum(:date)
  end

  def self.latest_date(season)
    self.where(season: season).maximum(:date)
  end

  def self.rebuild_all
     self.connection.execute("TRUNCATE table #{table_name};")
     game_count = 0
     Boxscore.find_each do |boxscore|
       # home team's game
       home_game = self.new(:boxscore_id => boxscore.id, :date => boxscore.date, :season => boxscore.season)
       home_game.team_id = boxscore.home_team_id
       home_game.home = true
       home_game.opponent_id = boxscore.away_team_id
       home_game.win = (boxscore.winning_team_id == boxscore.home_team_id)
       home_game.runs = boxscore.home_runs
       home_game.opponent_runs = boxscore.away_runs
       home_game.total_innings = boxscore.total_innings
       if(home_game.save!)
         game_count += 1
       end

       # away team's game
       away_game = self.new(:boxscore_id => boxscore.id, :date => boxscore.date, :season => boxscore.season)
       away_game.team_id = boxscore.away_team_id
       away_game.home = false
       away_game.opponent_id = boxscore.home_team_id
       away_game.win = (boxscore.winning_team_id == boxscore.away_team_id)
       away_game.runs = boxscore.away_runs
       away_game.opponent_runs = boxscore.home_runs
       away_game.total_innings = boxscore.total_innings
       if(away_game.save!)
         game_count += 1
       end
     end

     game_count
  end

  def score
    [runs,opponent_runs]
  end

end
