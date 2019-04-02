class InitialSchema < ActiveRecord::Migration[5.2]

  create_table "boxscores", force: :cascade do |t|
    t.string  "name",            limit: 255
    t.date    "date"
    t.string  "ballpark",        limit: 255
    t.integer "home_team_id",    limit: 4
    t.integer "away_team_id",    limit: 4
    t.integer "winning_team_id", limit: 4
    t.integer "home_runs",       limit: 4
    t.integer "away_runs",       limit: 4
    t.integer "total_innings",   limit: 4
    t.text    "stats",           limit: 65535
    t.text    "content",         limit: 65535
  end

  add_index "boxscores", ["name"], name: "name_ndx", unique: true
  add_index "boxscores", ["date"], name: "boxscore_date_ndx", unique: false

  create_table "games", force: :cascade do |t|
    t.integer "boxscore_id",   limit: 4
    t.date    "date"
    t.boolean "home"
    t.integer "team_id",       limit: 4
    t.integer "opponent_id",   limit: 4
    t.boolean "win"
    t.integer "runs",          limit: 4
    t.integer "opponent_runs", limit: 4
    t.integer "total_innings", limit: 4
  end

  add_index "games", ["team_id", "opponent_id", "win"], name: "team_win_ndx"
  add_index "games", ["date"], name: "game_date_ndx", unique: false

  create_table "innings", force: :cascade do |t|
    t.integer "boxscore_id",   limit: 4
    t.integer "team_id",       limit: 4
    t.integer "inning",        limit: 4
    t.integer "runs",          limit: 4
    t.integer "opponent_runs", limit: 4
  end

  add_index "innings", ["boxscore_id", "team_id", "inning"], name: "innings_ndx", unique: true

  create_table "owners", force: :cascade do |t|
    t.string   "uid",              limit: 255, default: "",    null: false
    t.string   "firstname",        limit: 255, default: "",    null: false
    t.string   "lastname",         limit: 255, default: "",    null: false
    t.string   "nickname",         limit: 255, default: "",    null: false
    t.string   "email",            limit: 255, default: "",    null: false
    t.string   "token",            limit: 40
    t.boolean  "is_admin",                     default: false
    t.datetime "last_login_at"
    t.integer  "primary_owner_id", limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "owners", ["email"], name: "index_owners_on_email", unique: true

  create_table "rebuilds", force: :cascade do |t|
    t.string   "group",          limit: 255
    t.string   "single_model",   limit: 255
    t.string   "single_action",  limit: 255
    t.boolean  "in_progress"
    t.datetime "started"
    t.datetime "finished"
    t.float    "run_time",       limit: 24
    t.string   "current_model",  limit: 255
    t.string   "current_action", limit: 255
    t.datetime "current_start"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "rebuild_results", limit: 16777215
  end

  add_index "rebuilds", ["created_at"], name: "created_ndx"

  create_table "records", force: :cascade do |t|
    t.date    "date"
    t.integer "games",             limit: 4
    t.integer "team_id",           limit: 4
    t.integer "wins",              limit: 4
    t.integer "losses",            limit: 4
    t.integer "wins_minus_losses", limit: 4
    t.integer "rf",                limit: 4
    t.integer "ra",                limit: 4
    t.float   "gb",                limit: 24
    t.string  "streak",            limit: 255
    t.integer "home_games",        limit: 4
    t.integer "home_wins",         limit: 4
    t.integer "road_games",        limit: 4
    t.integer "road_wins",         limit: 4
    t.integer "home_rf",           limit: 4
    t.integer "home_ra",           limit: 4
    t.integer "road_rf",           limit: 4
    t.integer "road_ra",           limit: 4
  end

  add_index "records", ["date", "team_id"], name: "records_ndx", unique: true

  create_table "teams", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4
    t.string   "name",       limit: 255, default: "", null: false
    t.string   "abbrev",     limit: 3,   default: "", null: false
    t.string   "league",     limit: 10,  default: "", null: false
    t.string   "division",   limit: 4,   default: "", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "teams", ["name"], name: "index_teams_on_name", unique: true

  create_table :uploads do |t|
    t.references :owner
    t.attachment :archivefile
    t.string :archivefile_fingerprint
    t.integer :processing_status, default: 0
    t.integer :rebuild_id, null: true
    t.timestamps
  end

  add_index "uploads", ["archivefile_fingerprint"], name: "fingerprint_ndx", unique: true


end
