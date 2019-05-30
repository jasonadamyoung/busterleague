class AddGameResultsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column(:games, :game_result_id, :integer, default: 0, null: false)
    remove_index "games", name: "boxscore_game_ndx"
    execute "UPDATE games set game_result_id = ABS(boxscore_id) where boxscore_id < 0"
    execute "UPDATE games set boxscore_id = 0 where boxscore_id < 0"
    add_index "games", ["game_result_id", "boxscore_id","home"], name: "boxscore_game_ndx", unique: true
  end
end
