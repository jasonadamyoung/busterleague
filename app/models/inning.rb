# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Inning < ApplicationRecord
  belongs_to :team
  belongs_to :boxscore
  
  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end

  def self.rebuild_all
    self.dump_data
    boxscores = Boxscore.all
    Boxscore.all.each do |boxscore|
      boxscore.create_innings
    end
  end

end
