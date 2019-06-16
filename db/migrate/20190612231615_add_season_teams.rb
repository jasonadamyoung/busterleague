class AddSeasonTeams < ActiveRecord::Migration[5.2]
  def change
    create_table "team_seasons", force: :cascade do |t|
      t.integer "season", limit: 2, null: false
      t.integer "team_id", limit: 2, null: false
      t.string "abbrev", limit: 3, default: "", null: false
      t.integer "owner_id", limit: 2, null: false
      t.string  "league", limit: 10, default: "", null: false
      t.string  "division", limit: 4, default: "", null: false
      t.integer "web_team_id", limit: 2
      t.boolean "div_win", null: false, default: false 
      t.boolean "lcs_win", null: false, default: false 
      t.boolean "ws_win", null: false, default: false 
      t.index ["season","team_id"], name: "ts_ndx", unique: true
    end
  end
end
