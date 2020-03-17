# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Boxscore < ApplicationRecord
  include ActiveModel::AttributeAssignment
  extend CleanupTools
  serialize :content

  belongs_to :game
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'
  belongs_to :winning_team, :class_name => 'Team'

  has_many :innings, dependent: :destroy
  has_many :game_batting_stats, dependent: :destroy
  has_many :game_pitching_stats, dependent: :destroy

  scope :for_season, lambda {|season| where(season: season)}
  scope :by_team_id, lambda {|team_id| where("home_team_id = #{team_id} or away_team_id = #{team_id}")}
  scope :waiting_for_data_records, -> {where(data_records_created: false)}

  def self.create_data_records_for_season(season,post_to_slack=true)
    processed_count = 0
    total_count = self.waiting_for_data_records.for_season(season).count
    self.waiting_for_data_records.for_season(season).find_each(batch_size: 100) do |bs|
      bs.create_data_records
      processed_count += 1
      if(processed_count % 100 == 0)
        SlackIt.post(message: "... Created data records for #{processed_count} of #{total_count} boxscores within Season: #{season}")
      end
    end
  end

  def create_data_records
    self.create_innings
    self.create_game_batting_stats
    self.create_game_pitching_stats
    self.update_attribute(:data_records_created, true)
  end

  def self.team_test_set(limit = 5)
    return_set = []
    Team.pluck(:id).each do |team_id|
      self.by_team_id(team_id).limit(limit).scoping do
        return_set += self.all
      end
    end
    return_set.uniq
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

  def reprocess
    self.innings.destroy_all
    self.game_batting_stats.destroy_all
    self.game_pitching_stats.destroy_all

    bp = self.parsed_content
    dtb_data = bp.date_teams_ballpark
    self.data_records_created = false
    if([2000,2001].include?(self.season))
      self.date = dtb_data['date'] - 1.year
    else
      self.date = dtb_data['date']
    end
    self.ballpark = dtb_data['ballpark']
    self.home_team_id = Team.id_for_abbreviation(dtb_data['home_team'])
    self.away_team_id = Team.id_for_abbreviation(dtb_data['away_team'])
    self.game_stats = {}
    innings_totals = bp.innings_totals
    self.home_runs = bp.innings_totals['home_runs']
    self.away_runs = bp.innings_totals['away_runs']
    self.total_innings = bp.innings_totals['total_innings']
    self.game_stats['innings_totals'] = innings_totals
    self.game_stats['batting_stats'] = bp.batting_stats
    self.game_stats['pitching_stats'] = bp.pitching_stats
    self.winning_team_id = ((innings_totals['home_runs'] > innings_totals['away_runs']) ? self.home_team_id : self.away_team_id)
    self.save!

    self.create_data_records
  end

  def self.create_or_update_from_game(game)
    season = game.season
    boxscore_name = game.boxscore_name

    return nil if season == 1999 || boxscore_name.blank?

    web_reports_url = "#{Settings.web_reports_base_url}/#{season}"

    if(!boxscore = Boxscore.where(game_id: game.id).first)
      boxscore = Boxscore.new(game_id: game.id, name: boxscore_name, season: season)
    end

    boxscore_url = "#{web_reports_url}/#{boxscore_name}.htm"
    if(array_content = self.get_boxscore_content_array_from_url(boxscore_url))
      boxscore.content = array_content
      bp = BoxscoreParser.new(boxscore.content)
      dtb_data = bp.date_teams_ballpark
      if([2000,2001].include?(boxscore.season))
        boxscore.date = dtb_data['date'] - 1.year
      else
        boxscore.date = dtb_data['date']
      end
      boxscore.ballpark = dtb_data['ballpark']
      boxscore.home_team_id = Team.id_for_abbreviation(dtb_data['home_team'])
      boxscore.away_team_id = Team.id_for_abbreviation(dtb_data['away_team'])
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
      return boxscore
    else
      return nil
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
    home_players = Roster.match_team_season_names(self.home_team_id,self.season,Roster.map_stats_to_name_hash(self.home_batting_stats))
    away_players = Roster.match_team_season_names(self.away_team_id,self.season,Roster.map_stats_to_name_hash(self.away_batting_stats))

    self.home_batting_stats.each do |name,stats|
      gbs = self.game_batting_stats.new
      gbs[:date] = self.date
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
      gbs[:date] = self.date
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
    home_players = Roster.match_team_season_names(self.home_team_id,self.season,Roster.map_stats_to_name_hash(self.home_pitching_stats,true))
    away_players = Roster.match_team_season_names(self.away_team_id,self.season,Roster.map_stats_to_name_hash(self.away_pitching_stats,true))

    self.home_pitching_stats.each do |name,stats|
      gps = self.game_pitching_stats.new
      gps[:date] = self.date
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
      gps[:date] = self.date
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
