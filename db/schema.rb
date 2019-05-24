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

ActiveRecord::Schema.define(version: 2019_05_24_183224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batting_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2, null: false
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "flag", limit: 1, default: "", null: false
    t.string "position", limit: 2, default: "", null: false
    t.float "avg"
    t.float "obp"
    t.float "spc"
    t.integer "ab"
    t.integer "h"
    t.integer "h2b"
    t.integer "h3b"
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
    t.integer "h1b", default: 0, null: false
    t.index ["roster_id", "name", "season", "team_id"], name: "batstat_ndx", unique: true
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
    t.jsonb "game_stats"
    t.boolean "data_records_created", default: false, null: false
    t.index ["date"], name: "boxscore_date_ndx"
    t.index ["name", "season"], name: "name_ndx", unique: true
    t.index ["season"], name: "boxscore_season_ndx"
  end

  create_table "game_batting_stats", force: :cascade do |t|
    t.integer "boxscore_id", limit: 2
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.integer "opposing_team_id", limit: 2, null: false
    t.integer "location", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "position", limit: 2, default: "", null: false
    t.integer "ab", default: 0, null: false
    t.integer "h", default: 0, null: false
    t.integer "h2b", default: 0, null: false
    t.integer "h3b", default: 0, null: false
    t.integer "hr", default: 0, null: false
    t.integer "r", default: 0, null: false
    t.integer "rbi", default: 0, null: false
    t.integer "hbp", default: 0, null: false
    t.integer "bb", default: 0, null: false
    t.integer "k", default: 0, null: false
    t.integer "sb", default: 0, null: false
    t.integer "cs", default: 0, null: false
    t.integer "gs", default: 0, null: false
    t.integer "pa", default: 0, null: false
    t.integer "sh", default: 0, null: false
    t.integer "sf", default: 0, null: false
    t.integer "gdp", default: 0, null: false
    t.integer "ebh", default: 0, null: false
    t.integer "tb", default: 0, null: false
    t.integer "h1b", default: 0, null: false
    t.integer "lineup", default: 0, null: false
    t.index ["boxscore_id", "name", "team_id"], name: "gbs_ndx", unique: true
  end

  create_table "game_pitching_stats", force: :cascade do |t|
    t.integer "boxscore_id", limit: 2
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.integer "opposing_team_id", limit: 2, null: false
    t.integer "location", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.integer "w", default: 0, null: false
    t.integer "l", default: 0, null: false
    t.integer "hold", default: 0, null: false
    t.integer "s", default: 0, null: false
    t.integer "bs", default: 0, null: false
    t.float "ip", default: 0.0, null: false
    t.integer "h"
    t.integer "r"
    t.integer "er"
    t.integer "bb"
    t.integer "k"
    t.integer "pch"
    t.integer "str"
    t.integer "hb"
    t.integer "balk"
    t.integer "wp"
    t.index ["boxscore_id", "name", "team_id"], name: "gps_ndx", unique: true
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

  create_table "pitching_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "flag", limit: 1, default: "", null: false
    t.string "position", limit: 2, default: "", null: false
    t.float "era"
    t.integer "w"
    t.integer "l"
    t.integer "s"
    t.integer "g"
    t.integer "gs"
    t.integer "cg"
    t.integer "sho"
    t.float "ip"
    t.integer "h"
    t.integer "r"
    t.integer "er"
    t.integer "bb"
    t.integer "k"
    t.integer "hr"
    t.integer "gdp"
    t.integer "bf"
    t.integer "sb"
    t.integer "cs"
    t.integer "iw"
    t.integer "hbp"
    t.integer "bk"
    t.integer "sh"
    t.integer "sf"
    t.integer "ci"
    t.float "h_per_9"
    t.float "bb_per_9"
    t.float "r_per_9"
    t.float "k_per_9"
    t.float "hr_per_9"
    t.float "k_per_bb"
    t.float "pch_per_g"
    t.float "str_percent"
    t.float "ops"
    t.float "whip"
    t.integer "bip"
    t.float "ipavg"
    t.integer "tbw"
    t.float "tbw_per_bf"
    t.integer "tbwh"
    t.float "tbwh_per_bf"
    t.float "rc"
    t.float "rc27"
    t.float "rcera"
    t.float "cera"
    t.float "cg_percent"
    t.integer "qs"
    t.float "qs_percent"
    t.integer "rs"
    t.float "rs_per_g"
    t.integer "rl"
    t.integer "rls"
    t.float "rl_percent"
    t.integer "svo"
    t.float "sv_percent"
    t.integer "bs"
    t.float "bs_percent"
    t.integer "hld"
    t.integer "ir"
    t.integer "irs"
    t.float "ir_percent"
    t.integer "gr"
    t.integer "gf"
    t.float "avg"
    t.float "obp"
    t.float "spc"
    t.integer "ab"
    t.integer "h1b"
    t.integer "h2b"
    t.integer "h3b"
    t.integer "tb"
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
    t.integer "l_hbp"
    t.integer "l_bb"
    t.integer "l_ibb"
    t.integer "l_k"
    t.integer "l_sh"
    t.integer "l_sf"
    t.integer "l_gdp"
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
    t.integer "r_hbp"
    t.integer "r_bb"
    t.integer "r_ibb"
    t.integer "r_k"
    t.integer "r_sh"
    t.integer "r_sf"
    t.integer "r_gdp"
    t.index ["name", "season", "team_id"], name: "pitchstat_ndx", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.string "buster_id", limit: 255, default: "", null: false
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "name", limit: 255, default: "", null: false
    t.integer "player_type", limit: 2, null: false
    t.integer "earliest_season", limit: 2, null: false
    t.integer "earliest_season_age", limit: 2, null: false
    t.string "bats", limit: 3, default: "", null: false
    t.string "throws", limit: 1, default: "", null: false
    t.string "positions", array: true
    t.integer "teams", array: true
    t.integer "seasons", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buster_id"], name: "player_ndx", unique: true
  end

  create_table "real_batting_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "position", limit: 2, default: "", null: false
    t.integer "age", limit: 2, null: false
    t.string "bats", limit: 2, default: "", null: false
    t.float "avg"
    t.float "obp"
    t.float "spc"
    t.integer "pa"
    t.integer "ab"
    t.integer "hr"
    t.integer "r"
    t.integer "rbi"
    t.integer "bb"
    t.integer "k"
    t.integer "sb"
    t.integer "gs"
    t.float "ops"
    t.float "rc"
    t.float "rc27"
    t.float "iso"
    t.integer "ebh"
    t.integer "tb"
    t.float "babip"
    t.float "woba"
    t.integer "wrcplus"
    t.float "war_fg"
    t.float "opsplus"
    t.float "war_br"
    t.float "l_avg"
    t.float "l_obp"
    t.float "l_spc"
    t.float "l_ops"
    t.integer "l_pa"
    t.float "r_avg"
    t.float "r_obp"
    t.float "r_spc"
    t.float "r_ops"
    t.integer "r_pa"
    t.index ["roster_id"], name: "rbs_roster_ndx", unique: true
  end

  create_table "real_pitching_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "position", limit: 2, default: "", null: false
    t.integer "age", limit: 2, null: false
    t.string "throws", limit: 2, default: "", null: false
    t.float "era"
    t.integer "w"
    t.integer "l"
    t.integer "s"
    t.integer "g"
    t.integer "gs"
    t.float "ip"
    t.integer "k"
    t.float "avg"
    t.float "obp"
    t.float "spc"
    t.float "ops"
    t.float "rc"
    t.float "rc27"
    t.float "rcera"
    t.float "cera"
    t.integer "eraplus"
    t.float "whip"
    t.float "h_per_9"
    t.float "k_per_9"
    t.float "bb_per_9"
    t.float "hr_per_9"
    t.float "k_per_bb"
    t.float "babip"
    t.float "fip"
    t.float "xfip"
    t.float "war_fg"
    t.float "war_br"
    t.float "l_avg"
    t.float "l_obp"
    t.float "l_spc"
    t.float "l_ops"
    t.integer "l_pa"
    t.float "r_avg"
    t.float "r_obp"
    t.float "r_spc"
    t.float "r_ops"
    t.integer "r_pa"
    t.index ["roster_id"], name: "rps_roster_ndx", unique: true
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
    t.string "end_name", limit: 255, default: "", null: false
    t.integer "age", limit: 2, null: false
    t.string "position", limit: 2, default: "", null: false
    t.string "bats", limit: 3, default: "", null: false
    t.string "throws", limit: 1, default: "", null: false
    t.jsonb "contract_data"
    t.jsonb "batting_data"
    t.jsonb "pitching_data"
    t.jsonb "fielding_data"
    t.string "status"
    t.integer "status_code"
    t.integer "trade_status"
    t.integer "trade_team_id"
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

  create_table "transaction_logs", force: :cascade do |t|
    t.string "hashid", limit: 255, null: false
    t.date "date", null: false
    t.integer "season", null: false
    t.integer "roster_id"
    t.string "name", limit: 255, default: "", null: false
    t.integer "action", null: false
    t.string "action_text", limit: 255, default: "", null: false
    t.integer "team_id", null: false
    t.string "team_string", limit: 4, default: "", null: false
    t.integer "other_team_id"
    t.string "other_team_string", limit: 4
    t.date "effective_date"
    t.string "when_string", limit: 255
    t.index ["hashid", "season"], name: "record_ndx", unique: true
    t.index ["name", "team_id"], name: "name_team_ndx"
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
    t.integer "season", default: 0, null: false
    t.index ["archivefile_fingerprint"], name: "fingerprint_ndx", unique: true
    t.index ["owner_id"], name: "index_uploads_on_owner_id"
  end

end
