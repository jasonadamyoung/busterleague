# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module StatTools
  extend ActiveSupport::Concern

  def create_or_update_stat(statdata)
    allowed_attributes = self.column_names
    allowed_attributes.delete_if {|name| name == 'id'}
    save_stats = {}
    statdata.each do |name,value|
      if(name == 'team_string')
        save_stats['team_id'] = Team.id_for_abbreviation(value)
      elsif(allowed_attributes.include?(name))
        save_stats[name] = value
      end
    end
    name = "#{save_stats['first_name']} #{save_stats['last_name']}"
    if(roster = Roster.find_roster_for_name_position_team_season(name,
                                                                 save_stats['position'],
                                                                 save_stats['team_id'],
                                                                 save_stats['season'],
                                                                 true))
      save_stats['roster_id'] = roster.id
    end


    if(!stat = self.where(roster_id: save_stats['roster_id']).first)
      stat = self.new
    end

    stat.assign_attributes(save_stats)
    stat.save!
    stat
  end

end
