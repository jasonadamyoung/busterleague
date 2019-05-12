# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Boxscore < ApplicationRecord
  include ActiveModel::AttributeAssignment
  serialize :content
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'
  belongs_to :winning_team, :class_name => 'Team'
  has_many :games
  has_many :innings
  has_many :game_batting_stats
  has_many :game_pitching_stats
  after_create :create_games, :create_innings, :create_game_batting_stats, :create_game_pitching_stats

  scope :for_season, lambda {|season| where(season: season)}
  scope :by_team_id, lambda {|team_id| where("home_team_id = #{team_id} or away_team_id = #{team_id}")}

  def self.team_test_set(limit = 5)
    return_set = []
    Team.pluck(:id).each do |team_id|
      self.by_team_id(team_id).limit(limit).scoping do
        return_set += self.all
      end
    end
    return_set.uniq
  end
         
  def self.dump_data
    Game.dump_data
    Inning.dump_data
    GameBattingStat.dump_data
    GamePitchingStat.dump_data
    Record.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

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
        boxscore.date = dtb_data['date']
        boxscore.ballpark = dtb_data['ballpark']
        boxscore.home_team_id = Team.where(abbrev: Team.abbreviation_transmogrifier(dtb_data['home_team'])).first.id
        boxscore.away_team_id = Team.where(abbrev: Team.abbreviation_transmogrifier(dtb_data['away_team'])).first.id
        boxscore.game_stats = {}
        innings_totals = bp.innings_totals
        boxscore.home_runs = bp.innings_totals['home_runs']
        boxscore.away_runs = bp.innings_totals['away_runs']
        boxscore.total_innings = bp.innings_totals['total_innings']
        

        boxscore.game_stats['innings_totals'] = innings_totals
        boxscore.game_stats['batting_stats'] = bp.batting_stats
        boxscore.game_stats['pitching_stats'] = bp.pitching_stats
        boxscore.winning_team_id = ((innings_totals['home_runs'] > innings_totals['away_runs']) ? boxscore.home_team_id : boxscore.away_team_id)
        boxscore.save!
        return true
      else
        return false
      end
    else
      return false
    end   
  end

  def update_boxscore_stats
    bp = self.parsed_content
    self.game_stats = {}
    self.game_stats['innings_totals'] = bp.innings_totals
    self.game_stats['batting_stats'] = bp.batting_stats
    self.game_stats['pitching_stats'] = bp.pitching_stats
    self.save!
  end

  def self.update_boxscore_stats
    self.find_each do |boxscore|
      boxscore.update_boxscore_stats
    end
  end

  def home_team_stats
    self.game_stats['innings_totals']['home_team_stats']
  end

  def away_team_stats
    self.game_stats['innings_totals']['away_team_stats']
  end

  def home_innings
    self.home_team_stats["innings"]
  end

  def away_innings
    self.away_team_stats["innings"]
  end

  def home_batting_stats
    self.game_stats['batting_stats']['home_batting_stats']
  end

  def away_batting_stats
    self.game_stats['batting_stats']['away_batting_stats']
  end

  def home_pitching_stats
    self.game_stats['pitching_stats']['home_pitching_stats']
  end

  def away_pitching_stats
    self.game_stats['pitching_stats']['away_pitching_stats']
  end

  def parsed_content
    if(@bsp.nil?)
      @bsp = BoxscoreParser.new(self.content)
    end
    @bsp
  end

  def create_games
    # home team's game
    home_game = Game.new(:boxscore_id => self.id, :date => self.date, :season => self.season)
    home_game.team_id = self.home_team_id
    home_game.home = true
    home_game.opponent_id = self.away_team_id
    home_game.win = (self.winning_team_id == self.home_team_id)
    home_game.runs = self.home_runs
    home_game.opponent_runs = self.away_runs
    home_game.hits = self.home_team_stats["hits"]
    home_game.opponent_hits = self.away_team_stats["hits"]  
    home_game.errs = self.home_team_stats["errors"]
    home_game.opponent_errs = self.away_team_stats["errors"]  
    home_game.total_innings = self.total_innings
    home_game.save!

    # away team's game
    away_game = Game.new(:boxscore_id => self.id, :date => self.date, :season => self.season)
    away_game.team_id = self.away_team_id
    away_game.home = false
    away_game.opponent_id = self.home_team_id
    away_game.win = (self.winning_team_id == self.away_team_id)
    away_game.runs = self.away_runs
    away_game.opponent_runs = self.home_runs
    away_game.hits = self.away_team_stats["hits"]
    away_game.opponent_hits = self.home_team_stats["hits"]  
    away_game.errs = self.away_team_stats["errors"]
    away_game.opponent_errs = self.home_team_stats["errors"]      
    away_game.total_innings = self.total_innings
    away_game.save!

    true
  end

  def create_innings
    home_innings = self.home_innings
    away_innings = self.away_innings
    for i in (1..self.total_innings)
      innings_offset = i-1
      if(home_innings[innings_offset])
        create_data = {:team_id => self.home_team_id, :inning => i, :runs => home_innings[innings_offset], :season => self.season}
        if(away_innings[innings_offset])
          create_data[:opponent_runs] = away_innings[innings_offset]
        end
        self.innings.create(create_data)
      end

      if(away_innings[innings_offset])
        create_data = {:team_id => self.away_team_id, :inning => i, :runs => away_innings[innings_offset], :season => self.season}
        if(home_innings[innings_offset])
          create_data[:opponent_runs] = home_innings[innings_offset]
        end
        self.innings.create(create_data)
      end
    end
    true
  end


  def create_game_batting_stats
    home_players = Roster.match_team_season_names(self.home_team_id,self.season,Roster.map_stats_to_name_hash(self.home_batting_stats),false)
    away_players = Roster.match_team_season_names(self.away_team_id,self.season,Roster.map_stats_to_name_hash(self.away_batting_stats),false)

    self.home_batting_stats.each do |name,stats|
      gbs = self.game_batting_stats.new
      gbs[:roster_id] = home_players[name]
      gbs[:name] = name
      gbs[:season] = self.season
      gbs[:team_id] = self.home_team_id
      gbs[:opposing_team_id] = self.away_team_id
      gbs[:location] = GameBattingStat::LOCATION_HOME
      gbs.assign_attributes(stats)
      gbs.save!
    end

    self.away_batting_stats.each do |name,stats|
      gbs = self.game_batting_stats.new
      gbs[:roster_id] = away_players[name]
      gbs[:name] = name
      gbs[:season] = self.season
      gbs[:team_id] = self.away_team_id
      gbs[:opposing_team_id] = self.home_team_id
      gbs[:location] = GameBattingStat::LOCATION_AWAY
      gbs.assign_attributes(stats)
      gbs.save!
    end
    true
  end

  def create_game_pitching_stats
    home_players = Roster.match_team_season_names(self.home_team_id,self.season,Roster.map_stats_to_name_hash(self.home_pitching_stats,true),true)
    away_players = Roster.match_team_season_names(self.away_team_id,self.season,Roster.map_stats_to_name_hash(self.away_pitching_stats,true),true)

    self.home_pitching_stats.each do |name,stats|
      gps = self.game_pitching_stats.new
      gps[:roster_id] = home_players[name]
      gps[:name] = name
      gps[:season] = self.season
      gps[:team_id] = self.home_team_id
      gps[:opposing_team_id] = self.away_team_id
      gps[:location] = GamePitchingStat::LOCATION_HOME
      gps.assign_attributes(stats)
      gps.save!
    end

    self.away_pitching_stats.each do |name,stats|
      gps = self.game_pitching_stats.new
      gps[:roster_id] = away_players[name]
      gps[:name] = name
      gps[:season] = self.season
      gps[:team_id] = self.away_team_id
      gps[:opposing_team_id] = self.home_team_id
      gps[:location] = GamePitchingStat::LOCATION_AWAY
      gps.assign_attributes(stats)
      gps.save!
    end
    true
  end
end
