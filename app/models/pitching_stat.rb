# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class PitchingStat < ApplicationRecord
  extend CleanupTools

  belongs_to :roster, optional: true
  belongs_to :player, optional: true
  belongs_to :team, optional: true

  before_save :set_singles

  scope :for_season, lambda {|season| where(season: season)}
  scope :totals, ->{where(is_total: true)}
  scope :players, ->{where("player_id <> #{NO_PLAYER}")}
  scope :ip_eligible, ->{where("ip >= (eligible_games * 1.0)")}
  scope :multi_team, ->{where(team_id: MULTIPLE_TEAM)}

  MULTIPLE_TEAM = 0
  NO_PLAYER = 0

  def self.rebuild_all
    self.dump_data
    Game.available_seasons.each do |season|
      Team.all.each do |team|
        team.update_pitching_stats_for_season(season)
      end
      self.update_total_pitching_stats_for_season(season)
    end
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
    eligible_games = Game.for_season(season).group('team_id').count.values.max || 162
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
        pitching_stat[:is_total] = true
        pitching_stat[:eligible_games] = eligible_games
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            pitching_stat[name] = value
          end
        end
        pitching_stat.save!
        pitching_stat.fix_total_flags
      else
        pitching_stat[:player_id] = player_id
        pitching_stat[:is_total] = true
        pitching_stat[:eligible_games] = eligible_games
        stats.each do |name,value|
          name = 'position' if(name == 'p') # relabel
          if(allowed_attributes.include?(name))
            pitching_stat[name] = value
          end
        end
        pitching_stat.save!
        pitching_stat.fix_total_flags
      end
    end
    total_pitching_data
  end

  def self.fix_total_flags
    self.multi_team.each do |stat|
      stat.fix_total_flags
    end
  end

  def fix_total_flags
    return false if(self.team_id != MULTIPLE_TEAM)
    return false if(self.player_id == NO_PLAYER)

    results = self.class.where(season: self.season).where(player_id: self.player_id).where("team_id <> ?",MULTIPLE_TEAM)
    results.each do |stat|
      stat.update_column(:is_total,false)
    end
    true
  end

end
