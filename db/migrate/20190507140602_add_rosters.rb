class AddRosters < ActiveRecord::Migration[5.2]
  def change

    create_table "rosters", force: :cascade do |t|
      t.integer   "player_id",   limit: 2
      t.integer   "season",      limit: 2, null: false
      t.integer   "team_id",     limit: 2, null: false
      t.string    "name",        limit: 255, default: "", null: false
      t.string    "end_name",    limit: 255, default: "", null: false
      t.integer   "age",         limit: 2, null: false
      t.string    "position",    limit: 2,   default: "", null: false
      t.string    "bats",        limit: 3,   default: "", null: false
      t.string    "throws",      limit: 1,   default: "", null: false
      t.jsonb     "contract_data"
      t.jsonb     "batting_data"
      t.jsonb     "pitching_data"
      t.jsonb     "fielding_data"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    add_index "rosters", ["name","position","age","season","team_id"], name: "roster_ndx", unique: true

  end
end
