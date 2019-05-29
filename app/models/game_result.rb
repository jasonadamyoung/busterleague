# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class GameResult < ApplicationRecord

  belongs_to :boxscore, optional: true
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'

  scope :for_season, lambda {|season| where(season: season)}


  def self.create_data_records_for_season(season)
    self.for_season(season).each do |gr|
      gr.create_data_records
    end
  end

  def create_data_records
    if(self.season == 1999)
      self.create_games
    end
    true
  end
  
  def create_games
    # home team's game
    home_game = Game.new(:boxscore_id => (0-self.id), :date => self.date, :season => self.season)
    home_game.team_id = self.home_team_id
    home_game.home = true
    home_game.opponent_id = self.away_team_id
    home_game.win = (self.home_runs > self.away_runs) ? true : false
    home_game.runs = self.home_runs
    home_game.opponent_runs = self.away_runs
    home_game.total_innings = self.total_innings
    home_game.save!

    # away team's game
    away_game = Game.new(:boxscore_id => (0-self.id), :date => self.date, :season => self.season)
    away_game.team_id = self.away_team_id
    away_game.home = false
    away_game.opponent_id = self.home_team_id
    away_game.win = (self.away_runs > self.home_runs) ? true : false
    away_game.runs = self.away_runs
    away_game.opponent_runs = self.home_runs
    away_game.total_innings = self.total_innings
    away_game.save!
    true
  end  

  def self.game_results_url(season)
    if(season != 1999)
      base_url = "#{Settings.web_reports_base_url}/#{season}"
      "#{base_url}/orggr.htm"
    else
      base_url = "#{Settings.web_reports_base_url}/#{season}"
      "#{base_url}/org1_orggr_1999.htm"
    end
  end

  def self.get_game_results_html(season)
    response = RestClient.get(self.game_results_url(season))
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

  def self.parsed_gameres_for_season(season)
    grp = GameResultsParser.new(self.get_game_results_html(season))
    grp
  end

  def self.get_teams(hash_data)
    return_data = {}
    return_data['home_team_id'] = Team.id_for_abbreviation(hash_data['home_team_string'])  
    return_data['away_team_id'] = Team.id_for_abbreviation(hash_data['away_team_string']) 
    return_data
  end

  def self.create_or_update_results_for_season(season)
    gr_data = self.parsed_gameres_for_season(season).game_results_data
    gr_data.each do |hashid,hash_data|
        if([2000,2001].include?(season))
          hash_data['date'] = hash_data['date'] - 1.year
        else
          hash_data['date']  = hash_data['date']
        end
        hash_data.merge!(self.get_teams(hash_data))

        if(gameres = self.where(date: hash_data['date'])
                         .where(season: season)
                         .where(home_team_id: hash_data['home_team_id'])
                         .where(away_team_id: hash_data['away_team_id'])
                         .first)
          gameres.assign_attributes(hash_data)
          gameres.save!
        else
          gameres = self.new(season: season)
          gameres.assign_attributes(hash_data)
          gameres.save!
        end       
    end
    true
  end

  

end