# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class PitchingStat < ApplicationRecord

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team

  before_save :set_singles

  scope :for_season, lambda {|season| where(season: season)}

  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def self.register_url(season)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    if(season == 1999)
      "#{base_url}/org1_orgpchreg_1999.htm"
    else
      "#{base_url}/orgpchreg.htm"
    end
  end

  def self.get_html(url)
    response = RestClient.get(url)
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

  def self.pitching_register_parser(season)
    PitchingRegisterParser.new(self.get_html(self.register_url(season)),"core_tables")
  end

  def self.get_pitching_data(season)
    prp = self.pitching_register_parser(season)
    prp.pitching_data
  end

  def set_singles
    self.h1b = (h - (h3b+h2b+hr))
  end

  def fix_roster_id
    if(roster = Roster.find_roster_for_name_position_team_season(self.name,
                                                                 self.position,
                                                                 self.team_id,
                                                                 self.season))
      self.update_attribute(:roster_id,roster.id)
    end
  end

  def self.fix_roster_ids
    self.where(roster_id: 0).where("name NOT IN ('Total')").find_each do |ps|
      ps.fix_roster_id
    end
  end

end

