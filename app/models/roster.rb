# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Roster < ApplicationRecord

  belongs_to :team
  # belongs_to :player

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

  def self.match_team_season_names(team_id,season,stats_hash,is_pitching)
    match_data = {}
    stats_hash.each do |name,stats|
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
      elsif(stats['position'] == 'p')
        player_finder = player_finder.pitchers
      end
      if(found_players = player_finder.all)
        if(found_players.size == 1)
          match_data[name] = found_players[0].player_id
        elsif(found_players.size > 1)
          # found more than one
          found_player_id = -1
          found_players.each do |player|
            matcher = Regexp.new("^#{startswith}")
            if(player.name =~ matcher)
              found_player_id = player.id
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


end
