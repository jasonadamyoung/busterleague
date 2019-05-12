# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Roster < ApplicationRecord

  belongs_to :team
  belongs_to :player, optional: true


  after_create :create_or_update_player

  scope :pitchers, -> { where(position: ['cl','mr','sp']) }
  scope :for_season, lambda {|season| where(season: season)}

  ADJUSTMENT_SEASON = 2000

  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def self.position_list
    self.group(:position).count
  end


  def buster_id
    "#{self.name.downcase.gsub(%r{[^a-z]},'')}_#{Player.position_type(self.position)}_#{self.adjusted_age}"
  end

  def adjusted_age
    self.age - (self.season - Roster::ADJUSTMENT_SEASON) + 42
  end

  def create_or_update_player
    player = Player.create_or_update_from_roster(self)
    self.update_attribute(:player_id, player.id)
  end

  def self.find_roster_for_name_position_team_season(name,position,team_id,season)
    namefinder = self.idiotic_shorthand_name_translations(name.dup)
    (lastname,startswith) = namefinder.split(',')
    if(lastname.last =~ %r{[A-Z]})
      startswith = lastname.last
      lastname.chop!
    end 
    nameparts = lastname.split("'")
    finder = nameparts.max_by(&:length)
    end_name = finder.downcase.split(' ').last
    player_finder = self.where(season: season).where(team_id: team_id).where("end_name ILIKE '%#{end_name}%'")
    if(position == 'p')
      player_finder = player_finder.pitchers
    end

    if(found_players = player_finder.all)
      if(found_players.size == 1)
        return found_players[0].id
      elsif(found_players.size > 1)
        # found more than one
        found_player_id = -1
        found_players.each do |roster_player|
          matcher = Regexp.new("^#{startswith}")
          if(roster_player.name =~ matcher)
            return roster_player.id
          end
        end
      else
        return 0
      end
    else
      return 0
    end
  end

  def self.match_team_season_names(team_id,season,names_hash)
    match_data = {}
    names_hash.each do |name,position|
      match_data[name] = self.find_roster_for_name_position_team_season(name,position,team_id,season)
    end
    match_data
  end

  def self.idiotic_shorthand_name_translations(name)
    case name
    when "H'lndswrth"
      "Hollandsworth"
    when "Ichiro"
      "Suzuki"
    when "DelosSntos"
      "Santos"
    when "LoDuca"
      "Duca"
    else
      name
    end
  end

  def self.map_stats_to_name_hash(stats,is_pitching = false)
    name_hash = {}
    if(is_pitching)
      stats.keys.each do |name|
        name_hash[name] = 'p'
      end
    else
      stats.each do |name,stats|
        if(stats['position'])
          name_hash[name] = stats['position']
        elsif(stats['p'])
          name_hash[name] = stats['p']
        else
          name_hash[name] = 'b'
        end
      end
    end
    name_hash
  end

end
