class AddPlayers < ActiveRecord::Migration[5.2]
  def change


    create_table "players", force: :cascade do |t|
      t.string    "buster_id",   limit: 255, default: "", null: false
      t.string    "first_name",   limit: 255, default: "", null: false
      t.string    "last_name",    limit: 255, default: "", null: false
      t.string    "name",         limit: 255, default: "", null: false
      t.integer   "player_type", limit: 2, null: false
      t.integer   "earliest_season", limit: 2, null: false
      t.integer   "earliest_season_age", limit: 2, null: false
      t.string    "bats",        limit: 3,   default: "", null: false
      t.string    "throws",      limit: 1,   default: "", null: false
      t.string    "positions",    array: true
      t.integer   "teams",    array: true
      t.integer   "seasons", array: true
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    add_index "players", ["buster_id"], name: "player_ndx", unique: true


  end
end
