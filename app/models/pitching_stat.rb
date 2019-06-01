# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class PitchingStat < ApplicationRecord

  belongs_to :roster, optional: true
  belongs_to :player, optional: true
  belongs_to :team, optional: true

  before_save :set_singles

  scope :for_season, lambda {|season| where(season: season)}

  MULTIPLE_TEAM = 0

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
    if(!self.h3b.blank? and !self.h2b.blank? and !self.hr.blank? and !self.h.blank?)
      self.h1b = (h - (h3b+h2b+hr))
    end
    true
  end

  def fix_roster_id
    if(roster = Roster.find_roster_for_name_position_team_season(self.name,
                                                                 self.position,
                                                                 self.team_id,
                                                                 self.season))
      self.update_attributes(roster_id: roster.id, player_id: roster.player_id, age: roster.age)
    end
  end

  def self.fix_roster_ids
    self.where(roster_id: 0).where("name NOT IN ('Total')").find_each do |ps|
      ps.fix_roster_id
    end
  end
 
  def self.find_player_id(player_details)
    if(!player_details['p'].blank?)
      position = player_details['p']
    elsif(!player_details['position'].blank?)
      position = player_details['position']
    end

    if(results = self.where(name: player_details['name']).where(age: player_details['age']).where(position: position).where("team_id <> ?",MULTIPLE_TEAM))
      results.first.player_id
    else
      nil
    end
  end

  def self.update_total_pitching_stats_for_season(season)
    allowed_attributes = PitchingStat.column_names
    all_pitching_data = self.get_pitching_data(season)
    total_pitching_data = all_pitching_data.select{|hashkey,data| data['team'].empty?}
    total_pitching_data.each do |hashkey,stats|
      player_id = self.find_player_id(stats)    
      name = stats['name']
      season = season
      if(!(pitching_stat = PitchingStat.where(season: season).where(roster_id: MULTIPLE_TEAM).where(team_id: MULTIPLE_TEAM).where(name: name).first))
        pitching_stat = PitchingStat.new(roster_id: MULTIPLE_TEAM, team_id: MULTIPLE_TEAM, season: season, name: name)
        pitching_stat[:player_id] = player_id
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            pitching_stat[name] = value
          end
        end
        pitching_stat.save!
      else
        pitching_stat[:player_id] = player_id
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            pitching_stat[name] = value
          end
        end
        pitching_stat.save!
      end
    end
    total_pitching_data
  end   

end

