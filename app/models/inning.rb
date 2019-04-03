# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Inning < ApplicationRecord
  belongs_to :team
    
  def self.rebuild
    self.connection.execute("TRUNCATE table #{table_name};")
    boxscores = Boxscore.all
    inning_count = 0
    Boxscore.all.each do |boxscore|
      home_innings = boxscore.home_innings
      away_innings = boxscore.away_innings
      for i in (1..boxscore.total_innings)
        if(home_innings[i])
          create_data = {:team_id => boxscore.home_team_id, :inning => i, :runs => home_innings[i]}
          if(away_innings[i])
            create_data[:opponent_runs] = away_innings[i]
          end
          boxscore.innings.create(create_data)
          inning_count += 1
        end

        if(away_innings[i])
          create_data = {:team_id => boxscore.away_team_id, :inning => i, :runs => away_innings[i]}
          if(home_innings[i])
            create_data[:opponent_runs] = home_innings[i]
          end
          boxscore.innings.create(create_data)
         inning_count += 1
        end
      end
    end
    inning_count
  end

end
