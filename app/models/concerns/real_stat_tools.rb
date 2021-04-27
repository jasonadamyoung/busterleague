# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module RealStatTools
  extend ActiveSupport::Concern


  def create_or_update_player
    # create/match to player
    player_details = {}
    player_details.merge!(self.attributes.reject{|key,value| ["id"].include?(key) })
    player_details['name'] = self.name
    if(player = Player.create_or_update_from_player_details(player_details['season'],player_details))
      self.update_attribute("player_id",player.id)
    end
  end


  module ClassMethods
    def create_or_update_stat(statdata)
      allowed_attributes = self.column_names.dup
      allowed_attributes.delete_if {|name| name == 'id'}
      # loop through the stats and set values if there's a matching attribute
      save_stats = {}
      statdata.each do |stat_name,stat_value|
        if(stat_name == 'team_string')
          if(!(team_id = Team.id_for_abbreviation(stat_value)))
            team_id = 0
          end
          save_stats['team_id'] = team_id
        elsif(allowed_attributes.include?(stat_name))
          save_stats[stat_name] = stat_value
        end
      end

      # create/match to player
      player_details = {}
      player_details.merge!(save_stats)
      player_details['name'] = "#{save_stats['first_name']} #{save_stats['last_name']}"
      if(player = Player.create_or_update_from_player_details(player_details['season'],player_details))
        save_stats['player_id'] = player.id
      end

      # match/create to existing stat
      finder_attributes = {}
      ["season", "first_name","last_name","position","age"].each do |find_stat|
        finder_attributes[find_stat] = save_stats[find_stat]
      end

      if(!stat = self.where(finder_attributes).first)
        stat = self.new
      end

      stat.assign_attributes(save_stats)
      stat.save!
      stat
    end
  end
end
