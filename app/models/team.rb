# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'stringio'

class Team < ApplicationRecord

  belongs_to :owner
  has_many :records
  has_many :games
  has_many :innings
  has_many :rosters
  has_many :players, through: :rosters
  has_many :game_batting_stats
  has_many :game_pitching_stats
  has_many :batting_stats
  has_many :pitching_stats
  has_many :transaction_logs


  scope :human, lambda { where("owner_id <> #{Owner.computer_id}")}
  scope :computer, lambda { where("owner_id = #{Owner.computer_id}")}

  scope :american, lambda { where(:league => 'American')}
  scope :national, lambda { where(:league => 'National')}
  scope :east, lambda { where(:division => 'East')}
  scope :west, lambda { where(:division => 'West')}

  scope :d1, lambda { where(:league => 'd1')}
  scope :d2, lambda { where(:league => 'd2')}

  def logo
    StringIO.new(self.svglogo)
  end
  
  def is_human?
    (owner_id != Owner.computer_id)
  end

  def wins_minus_losses(season,through_date)
    record_for_date = self.records.for_season(season).where(date: through_date).first
    if(record_for_date)
      record_for_date.wins_minus_losses
    else
      0
    end
  end

  def record_for_season(season)
    self.records.final_for_season(season).first
  end

  def win_pct_plot_data(season)
    win_pcts = []
    x_pcts = []
    self.records.for_season(season).where('games > 0').order('date ASC').each do |record|
      win_pcts << [record.date,(record.wins / record.games).to_f]
      exponent = ((record.rf + record.ra) / record.games )**0.287
      x_pcts << [record.date, ((record.rf**(exponent)) / ( (record.rf**(exponent)) + (record.ra**(exponent)) )).to_f]
    end
    {:labels => ['Win %','Expected %'],:data => [win_pcts] + [x_pcts]}
  end

  def self.win_pct_plot_data(season)
    labels = []
    data = []
      teamslist = self.order(:name)
      teamslist.each do |team|
        labels << team.name
        win_pcts = []
        team.records.for_season(season).where('games >= 7').order('date ASC').each do |record|
          win_pcts << [record.date,(record.wins / record.games).to_f]
        end
        data << win_pcts
      end
    {:labels => labels,:data => data}
  end


  def self.gb_plot_data(season)
    labels = []
    data = []
      teamslist = self.order(:name).to_a
      teamslist.each do |team|
        labels << team.name
        gbs = []
        team.records.for_season(season).where('games >= 0').order('date ASC').each do |record|
          gbs << [record.date,0-record.gb]
        end
        data << gbs
      end
    {:labels => labels,:data => data}
  end

  def self.abbreviation_transmogrifier(abbrev)
    case abbrev.upcase
    when 'CHA'
      'CWS'
    when 'CHN'
      'CHC'
    when 'NYN'
      'NYM'
    when 'NYA'
      'NYY'
    else
      abbrev.upcase
    end
  end

  def self.abbreviation_finder(abbrev)
    self.where(abbrev: self.abbreviation_transmogrifier(abbrev)).first
  end

  def self.id_for_abbreviation(abbrev)
    if(team = self.abbreviation_finder(abbrev))
      team.id
    else
      nil
    end
  end

  def roster_url(season)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    "#{base_url}/tm#{self.web_team_id}_tmroster.htm"
  end

  def batting_url(season)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    if(season == 1999)
      "#{base_url}/tm#{self.web_team_id_nn}_tmbat_1999.htm"
    else
      "#{base_url}/tm#{self.web_team_id}_tmbat.htm"
    end
  end

  def pitching_url(season,table_type)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    case table_type
    when 'core_tables'
      if(season == 1999)
        "#{base_url}/tm#{self.web_team_id_nn}_tmpch_1999.htm"
      else
        "#{base_url}/tm#{self.web_team_id}_tmpch.htm"
      end
    when 'batting_tables'
      if(season == 1999)
        "#{base_url}/tm#{self.web_team_id_nn}_tmpch2_1999.htm"
      else
        "#{base_url}/tm#{self.web_team_id}_tmpch2.htm"
      end
    else
      nil
    end      
  end

  def get_html(url)
    response = RestClient.get(url)
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

  def roster_parser(season)
    RosterParser.new(self.get_html(self.roster_url(season)))
  end

  def batting_register_parser(season)
    BattingRegisterParser.new(self.get_html(self.batting_url(season)))
  end

  def get_batting_data(season)
    brp = self.batting_register_parser(season)
    brp.batting_data
  end


  def pitching_register_parser(season,table_type)
    PitchingRegisterParser.new(self.get_html(self.pitching_url(season,table_type)),table_type)
  end

  def get_pitching_data(season)
    batting_pitching_data = self.pitching_register_parser(season,"batting_tables").pitching_data
    core_pitching_data = self.pitching_register_parser(season,"core_tables").pitching_data
    pitching_data = batting_pitching_data.deep_merge(core_pitching_data)
    pitching_data
  end


  def position_data_roster_matcher(position_data,season)
    # get the names out
    name_hash = {}
    position_data.each do |key,stats|
      next if stats['name'] == 'Total'
      next if stats['name'] == 'Pitchers'
      next if stats['name'] == 'Other'
      name_hash[stats['name']] = stats['p']
    end

    Roster.match_team_season_names(self.id,season,name_hash,true)
  end


  def update_batting_stats_for_season(season)
    eligible_games = self.games.for_season(season).count
    allowed_attributes = BattingStat.column_names
    batting_data = self.get_batting_data(season)
    name_matcher = position_data_roster_matcher(batting_data,season)
    batting_data.each do |hashkey,stats|
      name = stats['name']
      roster_id = name_matcher[name] || 0
      season = season
      if(!(batting_stat = self.batting_stats.where(season: season).where(roster_id: roster_id).where(name: name).first))
        if(roster = Roster.where(id: roster_id).first)
          batting_stat = self.batting_stats.new(roster_id: roster_id, season: season, name: name, player_id: roster.player_id, age: roster.age)
        else
          batting_stat = self.batting_stats.new(roster_id: roster_id, season: season, name: name)
        end
        batting_stat['eligible_games'] = eligible_games
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            batting_stat[name] = value
          end
        end
        batting_stat.save!
      else
        batting_stat['eligible_games'] = eligible_games
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            batting_stat[name] = value
          end
        end
        batting_stat.save!
      end
    end
    batting_data
  end

  def update_pitching_stats_for_season(season)
    eligible_games = self.games.for_season(season).count
    allowed_attributes = PitchingStat.column_names
    pitching_data = self.get_pitching_data(season)
    name_matcher = position_data_roster_matcher(pitching_data,season)
    pitching_data.each do |hashkey,stats|
      name = stats['name']
      roster_id = name_matcher[name] || 0
      season = season
      if(!(pitching_stat = self.pitching_stats.where(season: season).where(roster_id: roster_id).where(name: name).first))
        if(roster = Roster.where(id: roster_id).first)
          pitching_stat = self.pitching_stats.new(roster_id: roster_id, season: season, name: name, player_id: roster.player_id, age: roster.age)
        else
          pitching_stat = self.pitching_stats.new(roster_id: roster_id, season: season, name: name)
        end        
        pitching_stat['eligible_games'] = eligible_games
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            pitching_stat[name] = value
          end
        end
        pitching_stat.save!
      else
        pitching_stat['eligible_games'] = eligible_games
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            pitching_stat[name] = value
          end
        end
        pitching_stat.save!
      end
    end
    pitching_data
  end  

  def create_or_update_rosters_for_season(season)
    if(season == 1999)
      return 0
    end
    rp = self.roster_parser(season)
    rp.roster.each do |hashkey,player_details|
      Roster.create_or_update_roster_player_for_season_by_team(season,self,player_details)
    end
    self.roster.for_season(season).count
  end

  def create_or_update_traded_rosters_for_season(season)
    # go through the trades for this team, match to current roster, create for other team
    self.traded_for_season(season).each do |tl|
      traded_from_team = tl.other_team
      if(rp = Roster.find_roster_for_name_position_team_season(tl.name,'n/a',self,season))
        player_attributes = rp.attributes
        player_attributes.delete('id')
        player_attributes.delete('season')
        player_attributes.delete('player_id')
        player_attributes.delete('team_id')
        player_details = player_attributes
        player_details['status'] = 'traded'
        player_details['trade_status'] = Roster::TRADED
        player_details['trade_team_id'] = self.id
        orp = Roster.create_or_update_roster_player_for_season_by_team(season,traded_from_team,player_details)
        rp.update_attributes(:trade_status => Roster::ACQUIRED_TRADE, :trade_team_id => traded_from_team.id, original_roster_id: orp.id)
      end
    end
  end

  def traded_for_season(season)
    traded = self.transaction_logs.for_season(season).traded
    traded
  end

  def self.create_or_update_rosters_for_season(season)
    Team.all.each do |t|
      t.create_or_update_rosters_for_season(season)
    end

    Team.all.each do |t|
      t.create_or_update_traded_rosters_for_season(season)
    end
  end


  def self.update_batting_stats_for_season(season)
    Team.all.each do |t|
      t.update_batting_stats_for_season(season)
    end
  end    

  def self.update_pitching_stats_for_season(season)
    Team.all.each do |t|
      t.update_pitching_stats_for_season(season)
    end
  end
  
  def self.send_owner_emails
    self.human.each do |team|
      team.owner.send_update_email
    end
    true
  end

end
