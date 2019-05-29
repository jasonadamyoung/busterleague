class AddGameResults < ActiveRecord::Migration[5.2]
  def change
    create_table "game_results", force: :cascade do |t|
      t.integer "season"
      t.date    "date"
      t.string  "boxscore_name", limit: 255
      t.integer "boxscore_id"
      t.integer "home_team_id"
      t.string  "home_team_string", limit: 4
      t.integer "home_runs"
      t.integer "away_team_id"
      t.string  "away_team_string", limit: 4
      t.integer "away_runs"
      t.integer "total_innings"
      t.string  "winning_pitcher_name", limit: 255
      t.integer "winning_pitcher_id"
      t.string  "losing_pitcher_name", limit: 255
      t.integer "losing_pitcher_id"
      t.string  "save_pitcher_name", limit: 255
      t.integer "save_pitcher_id"
      t.string  "gwrbi_name", limit: 255
      t.integer "gwrbi_id"
      t.index ["date", "season","home_team_id","away_team_id"], name: "game_results_ndx", unique: true
    end


  end
end
