# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class TransactionLog < ApplicationRecord

  belongs_to :roster, optional: true
  belongs_to :team, optional: true
  belongs_to :other_team, class_name: 'Team', optional: true
  before_save :set_teams, :set_action

  scope :for_season, lambda {|season| where(season: season)}
  scope :traded, ->{where(action: ACQUIRED_TRADE)}

  # actions
  UNKNOWN = -1
  ADDED_TO_DL = 1
  REMOVED_FROM_DL = 2
  ACTIVE_ROSTER = 3
  RESERVED_ROSTER = 4
  SIGNED = 5
  RELEASED = 6
  TRADED = 7
  ACQUIRED_TRADE = 8

  # action_strings
  ACTION_TEXT_STRINGS = {
    ADDED_TO_DL => 'Placed on disabled list',
    REMOVED_FROM_DL => 'Activated from disabled list',
    ACTIVE_ROSTER => 'Promoted to active roster',
    RESERVED_ROSTER => 'Demoted to reserve roster',
    SIGNED => 'Signed',
    RELEASED => 'Released',
    TRADED => 'Traded away',
    ACQUIRED_TRADE => 'Acquired via trade'
  }


  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def self.transactions_url(season)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    "#{base_url}/orgtxnlog.htm"
  end

  def self.get_transactions_html(season)
    response = RestClient.get(self.transactions_url(season))
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

  def self.parsed_stl_for_season(season)
    tlp = TransactionLogParser.new(self.get_transactions_html(season))
    tlp
  end

  def set_teams
    self.team_id = Team.where(abbrev: Team.abbreviation_transmogrifier(self.team_string)).first.id
    if(!self.other_team_string.blank?)
      self.other_team_id = Team.where(abbrev: Team.abbreviation_transmogrifier(self.other_team_string)).first.id
    end
    true
  end

  def set_action
    strings_to_action = ACTION_TEXT_STRINGS.invert
    if(!strings_to_action[self.action_text].nil?)
      self.action = strings_to_action[self.action_text]
    else
      self.action = UNKNOWN
    end
  end

  def self.create_or_update_logs_for_season(season)
    log_data = self.parsed_stl_for_season(season).transaction_data
    log_data.each do |hashid,data|
      if(stl = self.where(hashid: hashid).where(season: season).first)
        stl.assign_attributes(data)
        stl.save!
      else
        stl = self.new(hashid: hashid, season: season)
        stl.assign_attributes(data)
        stl.save!
      end       
    end
    true
  end

  def self.update_roster_players_for_season(season)
    self.for_season(season).includes(:team).all.each do |tl|
      if(rp = Roster.find_roster_for_name_position_team_season(tl.name,'n/a',tl.team,season))
        tl.update_attribute(:roster_id,rp.id)
      end
    end
  end

end
