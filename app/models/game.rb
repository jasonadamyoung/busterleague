# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Game < ApplicationRecord
  extend CleanupTools

  has_one :boxscore
  has_many :team_games
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'

  scope :for_season, lambda {|season| where(season: season)}
  scope :no_hitters, -> { where("home_hits = 0 OR away_hits = 0") }
  scope :perfects, -> { where("(home_hits = 0 AND away_errs = 0) OR (away_hits = 0 and home_errs = 0)") }

  after_create :create_or_update_boxscore,:create_or_update_team_games

  def self.dump_all_data
    self.dump_data
    TeamGame.dump_data
    Boxscore.dump_data
    Inning.dump_data
    GameBattingStat.dump_data
    GamePitchingStat.dump_data
    Record.dump_data
    DailyRecord.dump_data
  end

  def self.current_season
    Date.today.year - 1
  end

  def self.available_seasons
    self.distinct.pluck(:season).sort
  end

  def self.latest_season
    self.maximum(:season)
  end

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

  def create_or_update_boxscore
    if(!self.boxscore_name.nil?)
      boxscore = Boxscore.create_or_update_from_game(self)
      if(boxscore)
        self.home_hits = boxscore.home_team_stats["hits"]
        self.away_hits = boxscore.away_team_stats["hits"]
        self.home_errs = boxscore.home_team_stats["errors"]
        self.away_errs = boxscore.away_team_stats["errors"]
        self.save!
      end
    end
    true
  end

  def create_or_update_team_games
    boxscore = self.boxscore

    if(!(home_game = TeamGame.where(game_id: self.id).where(home: true).first))
      home_game = TeamGame.new(:game_id => self.id, :date => self.date, :season => self.season)
    end
    home_game.team_id = self.home_team_id
    home_game.home = true
    home_game.opponent_id = self.away_team_id
    home_game.win = (self.home_runs > self.away_runs) ? true : false
    home_game.runs = self.home_runs
    home_game.opponent_runs = self.away_runs
    home_game.total_innings = self.total_innings
    if(boxscore)
      home_game.opponent_runs = boxscore.away_runs
      home_game.hits = boxscore.home_team_stats["hits"]
      home_game.opponent_hits = boxscore.away_team_stats["hits"]
      home_game.errs = boxscore.home_team_stats["errors"]
      home_game.opponent_errs = boxscore.away_team_stats["errors"]
    end
    home_game.save!

    # away team's game
    if(!(away_game = TeamGame.where(game_id: self.id).where(home: false).first))
      away_game = TeamGame.new(:game_id => self.id, :date => self.date, :season => self.season)
    end
    away_game.team_id = self.away_team_id
    away_game.home = false
    away_game.opponent_id = self.home_team_id
    away_game.win = (self.away_runs > self.home_runs) ? true : false
    away_game.runs = self.away_runs
    away_game.opponent_runs = self.home_runs
    away_game.total_innings = self.total_innings
    if(boxscore)
      away_game.opponent_runs = boxscore.home_runs
      away_game.hits = boxscore.away_team_stats["hits"]
      away_game.opponent_hits = boxscore.home_team_stats["hits"]
      away_game.errs = boxscore.away_team_stats["errors"]
      away_game.opponent_errs = boxscore.home_team_stats["errors"]
    end
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

  def self.parsed_gameresults_for_season(season)
    grp = GameResultsParser.new(self.get_game_results_html(season))
    grp
  end

  def self.get_teams(hash_data)
    return_data = {}
    return_data['home_team_id'] = Team.id_for_abbreviation(hash_data['home_team_string'])
    return_data['away_team_id'] = Team.id_for_abbreviation(hash_data['away_team_string'])
    return_data
  end

  def self.create_or_update_for_season(season)
    gr_data = self.parsed_gameresults_for_season(season).game_results_data
    gr_data.each do |hashid,hash_data|
      if([2000,2001].include?(season))
        hash_data['date'] = hash_data['date'] - 1.year
      else
        hash_data['date']  = hash_data['date']
      end
      hash_data.merge!(self.get_teams(hash_data))

      if(game = self.where(date: hash_data['date'])
                        .where(season: season)
                        .where(home_team_id: hash_data['home_team_id'])
                        .where(away_team_id: hash_data['away_team_id'])
                        .first)
                        game.assign_attributes(hash_data)
                        game.save!
      else
        game = self.new(season: season)
        game.assign_attributes(hash_data)
        game.save!
      end
    end
    true
  end



end