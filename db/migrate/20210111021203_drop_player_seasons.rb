class DropPlayerSeasons < ActiveRecord::Migration[5.2]
  def change
    drop_table(:player_seasons)
  end
end
