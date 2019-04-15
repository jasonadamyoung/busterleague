# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Inning < ApplicationRecord
  belongs_to :team
  belongs_to :boxscore
    
  def self.rebuild_all
    self.connection.execute("TRUNCATE table #{table_name};")
    boxscores = Boxscore.all
    Boxscore.all.each do |boxscore|
      boxscore.create_innings
    end
  end

end
