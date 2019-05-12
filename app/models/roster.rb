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

  def self.match_team_season_names(team_id,season,names_hash,is_pitching)
    match_data = {}
    names_hash.each do |name,position|
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
      if(is_pitching)
        player_finder = player_finder.pitchers
      elsif(position == 'p')
        player_finder = player_finder.pitchers
      end
      if(found_players = player_finder.all)
        if(found_players.size == 1)
          match_data[name] = found_players[0].id
        elsif(found_players.size > 1)
          # found more than one
          found_player_id = -1
          found_players.each do |roster_player|
            matcher = Regexp.new("^#{startswith}")
            if(roster_player.name =~ matcher)
              found_player_id = roster_player.id
            end
          end
          match_data[name] = found_player_id
        else
          match_data[name] = 0
        end
      else
        match_data[name] = 0
      end
    end
    match_data
  end


  def self.idiotic_shorthand_name_translations(name)
    case name
    when "H'lndswrth"
      "Hollandsworth"
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
