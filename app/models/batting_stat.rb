# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class BattingStat < ApplicationRecord

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
      "#{base_url}/org1_orgbatreg_1999.htm"
    else
      "#{base_url}/orgbatreg.htm"
    end
  end

  def self.get_html(url)
    response = RestClient.get(url)
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

  def self.batting_register_parser(season)
    BattingRegisterParser.new(self.get_html(self.register_url(season)))
  end

  def self.get_batting_data(season)
    brp = self.batting_register_parser(season)
    brp.batting_data
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
    self.where(roster_id: 0).where("name NOT IN ('Total','Pitchers','Other')").find_each do |bs|
      bs.fix_roster_id
    end
  end

end

