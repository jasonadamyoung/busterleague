# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Team < ApplicationRecord

  belongs_to :owner
  has_many :records
  has_many :games
  has_many :innings
  has_many :rosters


  scope :human, lambda { where("owner_id <> #{Owner.computer_id}")}
  scope :computer, lambda { where("owner_id = #{Owner.computer_id}")}

  scope :american, lambda { where(:league => 'American')}
  scope :national, lambda { where(:league => 'National')}
  scope :east, lambda { where(:division => 'East')}
  scope :west, lambda { where(:division => 'West')}

  scope :d1, lambda { where(:league => 'd1')}
  scope :d2, lambda { where(:league => 'd2')}

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

  # -----------------------------------
  # Class-level methods
  # -----------------------------------


  def self.standings(options = {})
    league = options[:league]
    division = options[:division]
    season = options[:season] || Game.current_season
    date = options[:date] || Game.latest_date(season)
  

    teamlist = Team.where(:league => league).where(:division => division).load.to_a
    teamlist.sort!{|a,b| b.wins_minus_losses(season,date) <=> a.wins_minus_losses(season,date) }
    teamlist
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

  def roster_url(season)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    "#{base_url}/tm#{self.web_team_id}_tmroster.htm"
  end

  def get_roster_html(season)
    response = RestClient.get(self.roster_url(season))
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

  def create_rosters(season)
    rp = RosterParser.new(self.get_roster_html(season))
    rp.roster.each do |hashkey,player_details|
      if(!(roster = self.rosters.where(season: season).where(name: player_details['name']).first))
        roster = self.rosters.create(season: season,
                                     name: player_details['name'],
                                     age: player_details['age'], 
                                     position: player_details['position'], 
                                     bats: player_details['bats'],
                                     throws: player_details['throws'],
                                     contract_data: player_details)
      else
        roster.update_attributes(age: player_details['age'], 
                                  position: player_details['position'], 
                                  bats: player_details['bats'],
                                  throws: player_details['throws'],
                                  contract_data: player_details)
      end
    end
  end

  def self.create_rosters(season)
    Team.all.each do |t|
      t.create_rosters(season)
    end
  end

end
