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
  scope :through_date, lambda {|date| where("date <= ?",date)}

  def self.rebuild
     self.connection.execute("TRUNCATE table #{table_name};")
     game_count = 0
     Boxscore.all.each do |boxscore|
       # home team's game
       home_game = self.new(:boxscore_id => boxscore.id, :date => boxscore.date)
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
       away_game = self.new(:boxscore_id => boxscore.id, :date => boxscore.date)
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

  def self.earliest_date
    self.minimum(:date)
  end

  def self.latest_date
    self.maximum(:date)
  end

  def score
    [runs,opponent_runs]
  end

end
