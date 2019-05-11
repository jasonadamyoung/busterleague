# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_07_184027) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batting_stats", force: :cascade do |t|
    t.integer "player_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "flag", limit: 1, default: "", null: false
    t.string "position", limit: 2, default: "", null: false
    t.integer "age", limit: 2, null: false
    t.float "avg"
    t.float "obp"
    t.float "spc"
    t.integer "ab"
    t.integer "h"
    t.integer "2b"
    t.integer "3b"
    t.integer "hr"
    t.integer "r"
    t.integer "rbi"
    t.integer "hbp"
    t.integer "bb"
    t.integer "k"
    t.integer "sb"
    t.integer "cs"
    t.integer "gs"
    t.integer "pa"
    t.integer "sh"
    t.integer "sf"
    t.integer "gdp"
    t.float "ops"
    t.float "rc"
    t.float "rc27"
    t.float "iso"
    t.float "tavg"
    t.float "sec"
    t.integer "ebh"
    t.integer "tb"
    t.float "pa_per_g"
    t.float "ab_per_g"
    t.integer "bip"
    t.float "ipavg"
    t.integer "tbw"
    t.float "tbw_per_pa"
    t.integer "tbwh"
    t.float "tbwh_per_pa"
    t.float "k_per_bb"
    t.float "l_avg"
    t.float "l_obp"
    t.float "l_spc"
    t.float "l_ops"
    t.integer "l_ab"
    t.integer "l_h"
    t.integer "l_2b"
    t.integer "l_3b"
    t.integer "l_hr"
    t.integer "l_rbi"
    t.integer "l_bb"
    t.integer "l_k"
    t.float "r_avg"
    t.float "r_obp"
    t.float "r_spc"
    t.float "r_ops"
    t.integer "r_ab"
    t.integer "r_h"
    t.integer "r_2b"
    t.integer "r_3b"
    t.integer "r_hr"
    t.integer "r_rbi"
    t.integer "r_bb"
    t.integer "r_k"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "season", "team_id"], name: "batstat_ndx", unique: true
  end

  create_table "boxscores", force: :cascade do |t|
    t.string "name", limit: 255
    t.date "date"
    t.integer "season"
    t.string "ballpark", limit: 255
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "winning_team_id"
    t.integer "home_runs"
    t.integer "away_runs"
    t.integer "total_innings"
    t.text "content"
    t.jsonb "home_team_stats"
    t.jsonb "away_team_stats"
    t.jsonb "home_batting_stats"
    t.jsonb "home_pitching_stats"
    t.jsonb "away_batting_stats"
    t.jsonb "away_pitching_stats"
    t.index ["date"], name: "boxscore_date_ndx"
    t.index ["name", "season"], name: "name_ndx", unique: true
    t.index ["season"], name: "boxscore_season_ndx"
  end

  create_table "games", force: :cascade do |t|
    t.integer "boxscore_id"
    t.date "date"
    t.integer "season"
    t.boolean "home"
    t.integer "team_id"
    t.integer "opponent_id"
    t.boolean "win"
    t.integer "runs"
    t.integer "opponent_runs"
    t.integer "total_innings"
    t.integer "hits"
    t.integer "opponent_hits"
    t.integer "errs"
    t.integer "opponent_errs"
    t.index ["boxscore_id", "home"], name: "boxscore_game_ndx", unique: true
    t.index ["date"], name: "game_date_ndx"
    t.index ["season"], name: "game_season_ndx"
    t.index ["team_id", "opponent_id", "win"], name: "team_win_ndx"
  end

  create_table "innings", force: :cascade do |t|
    t.integer "boxscore_id"
    t.integer "season"
    t.integer "team_id"
    t.integer "inning"
    t.integer "runs"
    t.integer "opponent_runs"
    t.index ["boxscore_id", "team_id", "inning"], name: "innings_ndx", unique: true
  end

  create_table "owners", force: :cascade do |t|
    t.string "uid", limit: 255, default: "", null: false
    t.string "firstname", limit: 255, default: "", null: false
    t.string "lastname", limit: 255, default: "", null: false
    t.string "nickname", limit: 255, default: "", null: false
    t.string "email", limit: 255, default: "", null: false
    t.string "token", limit: 40
    t.boolean "is_admin", default: false
    t.datetime "last_login_at"
    t.integer "primary_owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_owners_on_email", unique: true
  end

  create_table "records", force: :cascade do |t|
    t.date "date"
    t.integer "season"
    t.integer "games"
    t.integer "team_id"
    t.integer "wins"
    t.integer "losses"
    t.integer "wins_minus_losses"
    t.integer "rf"
    t.integer "ra"
    t.float "gb"
    t.string "streak", limit: 255
    t.integer "home_games"
    t.integer "home_wins"
    t.integer "road_games"
    t.integer "road_wins"
    t.integer "home_rf"
    t.integer "home_ra"
    t.integer "road_rf"
    t.integer "road_ra"
    t.index ["date", "season", "team_id"], name: "records_ndx", unique: true
  end

  create_table "rosters", force: :cascade do |t|
    t.integer "player_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.integer "age", limit: 2, null: false
    t.string "position", limit: 2, default: "", null: false
    t.string "bats", limit: 3, default: "", null: false
    t.string "throws", limit: 1, default: "", null: false
    t.jsonb "contract_data"
    t.jsonb "batting_data"
    t.jsonb "pitching_data"
    t.jsonb "fielding_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "position", "age", "season", "team_id"], name: "roster_ndx", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.integer "owner_id"
    t.string "name", limit: 255, default: "", null: false
    t.string "abbrev", limit: 3, default: "", null: false
    t.string "league", limit: 10, default: "", null: false
    t.string "division", limit: 4, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "web_team_id", limit: 2
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "uploads", force: :cascade do |t|
    t.bigint "owner_id"
    t.string "archivefile_file_name"
    t.string "archivefile_content_type"
    t.bigint "archivefile_file_size"
    t.datetime "archivefile_updated_at"
    t.string "archivefile_fingerprint"
    t.integer "processing_status", default: 0
    t.integer "rebuild_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archivefile_fingerprint"], name: "fingerprint_ndx", unique: true
    t.index ["owner_id"], name: "index_uploads_on_owner_id"
  end

end
