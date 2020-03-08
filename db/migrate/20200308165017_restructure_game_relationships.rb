class RestructureGameRelationships < ActiveRecord::Migration[5.2]
  def change
    # rename tables
    rename_table "games", "team_games"
    rename_table "game_results", "games"

    remove_column "team_games", "boxscore_id"
    remove_column "games", "boxscore_id"

    rename_column(:team_games, "game_result_id","game_id")
    add_column(:boxscores, :game_id, :integer, default: 0, null: false)

    add_index "boxscores", ["game_id"], name: "boxscore_game_ndx", unique: true
    add_index "team_games", ["game_id", "home"], name: "teamgame_game_ndx", unique: true
  end
end
