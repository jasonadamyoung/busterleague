class AddPlayingTime < ActiveRecord::Migration[5.2]
  def change
    create_table "pitcher_playing_times", force: :cascade do |t|
      t.integer "season", limit: 2, null: false
      t.integer "roster_id", limit: 2, null: false
      t.integer "total_games"
      t.float   "actual_ip"
      t.integer "qualifying_ip"
      t.float   "ip"
      t.boolean "qualified"
      t.index ["season","roster_id"], name: "ppt_ndx", unique: true
    end

    create_table "batter_playing_times", force: :cascade do |t|
      t.integer "season", limit: 2, null: false
      t.integer "roster_id", limit: 2, null: false
      t.integer "total_games"
      t.integer "actual_ab"
      t.integer "qualifying_ab"
      t.float   "allowed_percentage"
      t.integer "allowed_starts"
      t.float   "played_percentage"
      t.integer "gs"
      t.integer "ab"
      t.boolean "qualified"
      t.index ["season","roster_id"], name: "bpt_ndx", unique: true
    end
  end
end
