class FixBoxscoreIds < ActiveRecord::Migration[6.1]
  def change
    change_column :game_batting_stats, :boxscore_id, :int
    change_column :game_pitching_stats, :boxscore_id, :int
    change_column :rosters, :player_id, :int
  end
end
