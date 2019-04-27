# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Boxscore < ApplicationRecord
  require 'pp'
  serialize :content
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'
  belongs_to :winning_team, :class_name => 'Team'
  has_many :games
  has_many :innings
  has_one :boxstat
  # after_create :create_games, :create_innings

  def self.download_and_process_for_season(season = Game.current_season)
    web_reports_url = "#{Settings.web_reports_base_url}/#{season}"
    all_boxscores = self.download_boxscores_for_season(season)
    processed = 0
    all_boxscores.each do |boxscore_name|
      if(Boxscore.get_and_create(web_reports_url,boxscore_name,season))
          processed +=1
      end
    end
    {total: all_boxscores.size, processed:  processed}
  end

  def self.download_boxscores_for_season(season)
    web_reports_url = "#{Settings.web_reports_base_url}/#{season}"
    self.download_boxscore_list(web_reports_url,Settings.game_results_page)
  end

  def self.download_boxscore_list(web_reports_url,game_results_page)
    results_list = []
    game_results_url = "#{web_reports_url}/#{game_results_page}"
    response = RestClient.get(game_results_url)
    if(!response.code == 200)
      return nil
    end
    htmldata = response.to_str
    doc = Nokogiri::HTML(htmldata)
    doc.search("a").each do |anchor|
      if(anchor['href'] and md = anchor['href'].match(%r{(?<boxscore>\d+)\.htm}))
        results_list << md[:boxscore]
      end
    end

    results_list
  end

  def self.get_boxscore_content_array_from_url(boxscore_url)
    response = RestClient.get(boxscore_url)
    if(!response.code == 200)
      return nil
    end
    htmldata = response.to_str

    array_content = []
    doc = Nokogiri::HTML(htmldata)
    doc.search("pre").each do |pre_texts|
      pre_texts.content.each_line do |line|
        array_content << line.chomp
      end
    end

    # pop the top
    if(array_content.first.blank?)
      array_content.shift
    end

    array_content
  end

  def self.get_and_create(web_reports_url,boxscore_name,season)
    if(!boxscore = Boxscore.where(season: season).where(name: boxscore_name).first)
      boxscore = Boxscore.new(:name => boxscore_name)
      boxscore_url = "#{web_reports_url}/#{boxscore_name}.htm"
      if(array_content = self.get_boxscore_content_array_from_url(boxscore_url))
        boxscore.season = season
        boxscore.content = array_content
        bp = BoxscoreParser.new(boxscore.content)
        dtb_data = bp.date_teams_ballpark
        boxscore.date = dtb_data[:date]
        boxscore.ballpark = dtb_data[:ballpark]
        boxscore.home_team_id = Team.where(abbrev: Team.abbreviation_transmogrifier(dtb_data[:home_team])).first.id
        boxscore.away_team_id = Team.where(abbrev: Team.abbreviation_transmogrifier(dtb_data[:away_team])).first.id
        boxstatdata = bp.innings_totals
        boxscore.winning_team_id = ((boxstatdata[:home_runs] > boxstatdata[:away_runs]) ? boxscore.home_team_id : boxscore.away_team_id)
        boxscore.build_boxstat(boxstatdata)
        boxscore.save!
        return true
      else
        return false
      end
    else
      return false
    end   
  end

  def create_games
    boxstat = self.boxstat
    # home team's game
    home_game = Game.new(:boxscore_id => self.id, :date => self.date, :season => self.season)
    home_game.team_id = self.home_team_id
    home_game.home = true
    home_game.opponent_id = self.away_team_id
    home_game.win = (self.winning_team_id == self.home_team_id)
    home_game.runs = boxstat.home_runs
    home_game.opponent_runs = boxstat.away_runs
    home_game.hits = boxstat.home_team["hits"]
    home_game.opponent_hits = boxstat.away_team["hits"]  
    home_game.errs = boxstat.home_team["errors"]
    home_game.opponent_errs = boxstat.away_team["errors"]  
    home_game.total_innings = boxstat.total_innings
    home_game.save!

    # away team's game
    away_game = Game.new(:boxscore_id => self.id, :date => self.date, :season => self.season)
    away_game.team_id = self.away_team_id
    away_game.home = false
    away_game.opponent_id = self.home_team_id
    away_game.win = (self.winning_team_id == self.away_team_id)
    away_game.runs = boxstat.away_runs
    away_game.opponent_runs = boxstat.home_runs
    away_game.hits = boxstat.away_team["hits"]
    away_game.opponent_hits = boxstat.home_team["hits"]  
    away_game.errs = boxstat.away_team["errors"]
    away_game.opponent_errs = boxstat.home_team["errors"]      
    away_game.total_innings = boxstat.total_innings
    away_game.save!
  end

  def create_innings
    boxstat = self.boxstat
    home_innings = boxstat.home_innings
    away_innings = boxstat.away_innings
    for i in (1..boxstat.total_innings)
      if(home_innings[i])
        create_data = {:team_id => self.home_team_id, :inning => i, :runs => home_innings[i], :season => self.season}
        if(away_innings[i])
          create_data[:opponent_runs] = away_innings[i]
        end
        self.innings.create(create_data)
      end

      if(away_innings[i])
        create_data = {:team_id => self.away_team_id, :inning => i, :runs => away_innings[i], :season => self.season}
        if(home_innings[i])
          create_data[:opponent_runs] = home_innings[i]
        end
        self.innings.create(create_data)
      end
    end
  end



end
