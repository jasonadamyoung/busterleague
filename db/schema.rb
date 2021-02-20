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

ActiveRecord::Schema.define(version: 2021_02_14_151854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batter_playing_times", force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "roster_id", limit: 2, null: false
    t.integer "total_games"
    t.integer "actual_ab"
    t.integer "qualifying_ab"
    t.float "allowed_percentage"
    t.integer "allowed_starts"
    t.float "played_percentage"
    t.integer "gs"
    t.integer "ab"
    t.boolean "qualified"
    t.index ["season", "roster_id"], name: "bpt_ndx", unique: true
  end

  create_table "batting_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2, null: false
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "flag", limit: 1, default: "", null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "g"
    t.integer "age"
    t.integer "player_id"
    t.integer "eligible_games", default: 0, null: false
    t.boolean "is_total", default: true, null: false
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
    t.integer "game_id", default: 0, null: false
    t.index ["date"], name: "boxscore_date_ndx"
    t.index ["game_id"], name: "boxscore_game_ndx", unique: true
    t.index ["name", "season"], name: "name_ndx", unique: true
    t.index ["season"], name: "boxscore_season_ndx"
  end

  create_table "daily_records", force: :cascade do |t|
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
    t.float "league_gb"
    t.float "overall_gb"
    t.string "streak", limit: 255
    t.integer "home_games"
    t.integer "home_wins"
    t.integer "road_games"
    t.integer "road_wins"
    t.integer "home_rf"
    t.integer "home_ra"
    t.integer "road_rf"
    t.integer "road_ra"
    t.string "last_ten", array: true
    t.jsonb "wl_groups"
    t.jsonb "records_by_opponent"
    t.index ["date", "season", "team_id"], name: "daily_records_ndx", unique: true
  end

  create_table "defined_stats", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "player_type", default: 1, null: false
    t.integer "category_code", default: 0, null: false
    t.integer "sort_direction", default: 1, null: false
    t.integer "stat_code", default: 1, null: false
    t.integer "default_display_order", default: 999, null: false
    t.text "definition"
    t.string "display_label"
    t.index ["name", "player_type"], name: "defined_stat_ndx", unique: true
  end

  create_table "draft_batting_statlines", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "player_id", default: 0
    t.string "abbrev", limit: 3
    t.string "injury", limit: 10
    t.string "stl", limit: 10
    t.string "run", limit: 10
    t.string "pos_c", limit: 10
    t.string "pos_1b", limit: 10
    t.string "pos_2b", limit: 10
    t.string "pos_3b", limit: 10
    t.string "pos_ss", limit: 10
    t.string "pos_lf", limit: 10
    t.string "pos_rf", limit: 10
    t.string "pos_cf", limit: 10
    t.string "cthr", limit: 10
    t.string "othr", limit: 10
  end

  create_table "draft_owner_ranks", id: :serial, force: :cascade do |t|
    t.integer "owner_id", default: 0
    t.integer "draft_player_id", default: 0
    t.integer "overall", default: 9999
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "draft_player_id"], name: "draft_owner_rank_owner_player_ndx", unique: true
  end

  create_table "draft_picks", id: :serial, force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "team_id", default: 0, null: false
    t.integer "draft_player_id", default: 0
    t.boolean "traded", default: false
    t.integer "original_team_id", default: 0
    t.integer "round", default: 0
    t.integer "roundpick", default: 0
    t.integer "overallpick", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "draft_pitching_statlines", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "player_id", default: 0
    t.string "abbrev", limit: 3
    t.string "injury", limit: 10
    t.string "rdur", limit: 10
    t.string "sdur", limit: 10
  end

  create_table "draft_players", id: :serial, force: :cascade do |t|
    t.integer "season"
    t.bigint "player_id"
    t.bigint "roster_id"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "position", limit: 3, default: "", null: false
    t.integer "age", default: 0, null: false
    t.string "type", default: "0"
    t.integer "statline_id", default: 0
    t.integer "team_id", default: 0, null: false
    t.integer "original_team_id", default: 0, null: false
    t.integer "draftstatus", default: 2, null: false
    t.datetime "updated_at"
    t.index ["draftstatus"], name: "draftplayers_draftstatus_ndx"
    t.index ["last_name", "first_name"], name: "draftplayers_name_ndx"
    t.index ["player_id"], name: "index_draft_players_on_player_id"
    t.index ["position"], name: "draftplayers_position_ndx"
    t.index ["roster_id"], name: "index_draft_players_on_roster_id"
    t.index ["statline_id"], name: "draftplayers_statline_ndx"
    t.index ["type"], name: "draftplayers_type_ndx"
  end

  create_table "draft_positions", id: :serial, force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "position"
    t.integer "team_id"
    t.index ["team_id", "season"], name: "draft_pos_season_team_ndx"
  end

  create_table "draft_ranking_values", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "owner_id", default: 1
    t.integer "playertype", default: 1
    t.text "formula"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "draft_rankings", id: :serial, force: :cascade do |t|
    t.integer "draft_ranking_value_id", default: 0
    t.integer "draft_player_id", default: 0
    t.float "value", default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["draft_ranking_value_id", "draft_player_id"], name: "rv_player", unique: true
    t.index ["value"], name: "by_value"
  end

  create_table "draft_stat_distributions", id: :serial, force: :cascade do |t|
    t.bigint "defined_stat_id"
    t.integer "player_type", default: 1
    t.string "label"
    t.string "name"
    t.float "mean"
    t.float "max"
    t.float "min"
    t.float "median"
    t.float "range"
    t.text "distribution"
    t.text "scaled_distribution"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["defined_stat_id"], name: "index_draft_stat_distributions_on_defined_stat_id"
  end

  create_table "draft_stat_preferences", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "owner_id", default: 1
    t.integer "playertype", default: 1
    t.text "column_list"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "playertype"], name: "draft_sp_ndx"
  end

  create_table "draft_wanteds", id: :serial, force: :cascade do |t|
    t.integer "owner_id", default: 1
    t.integer "draft_player_id", default: 0
    t.text "notes"
    t.string "highlight", default: "ffff00"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["owner_id", "draft_player_id"], name: "draft_wanted_ndx", unique: true
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
    t.date "date"
    t.integer "game_id"
    t.integer "player_id"
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
    t.date "date"
    t.integer "game_id"
    t.integer "player_id"
    t.index ["boxscore_id", "name", "team_id"], name: "gps_ndx", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.integer "season"
    t.date "date"
    t.string "boxscore_name", limit: 255
    t.integer "home_team_id"
    t.string "home_team_string", limit: 4
    t.integer "home_runs"
    t.integer "away_team_id"
    t.string "away_team_string", limit: 4
    t.integer "away_runs"
    t.integer "total_innings"
    t.string "winning_pitcher_name", limit: 255
    t.integer "winning_pitcher_id"
    t.string "losing_pitcher_name", limit: 255
    t.integer "losing_pitcher_id"
    t.string "save_pitcher_name", limit: 255
    t.integer "save_pitcher_id"
    t.string "gwrbi_name", limit: 255
    t.integer "gwrbi_id"
    t.integer "home_hits"
    t.integer "away_hits"
    t.integer "home_errs"
    t.integer "away_errs"
    t.index ["date", "season", "home_team_id", "away_team_id"], name: "game_results_ndx", unique: true
  end

  create_table "innings", force: :cascade do |t|
    t.integer "boxscore_id"
    t.integer "season"
    t.integer "team_id"
    t.integer "inning"
    t.integer "runs"
    t.integer "opponent_runs"
    t.integer "game_id"
    t.index ["boxscore_id", "team_id", "inning"], name: "innings_ndx", unique: true
  end

  create_table "owners", force: :cascade do |t|
    t.string "uid", limit: 255, default: "", null: false
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
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

  create_table "pitcher_playing_times", force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "roster_id", limit: 2, null: false
    t.integer "total_games"
    t.float "actual_ip"
    t.integer "qualifying_ip"
    t.float "ip"
    t.boolean "qualified"
    t.index ["season", "roster_id"], name: "ppt_ndx", unique: true
  end

  create_table "pitching_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "flag", limit: 1, default: "", null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "age"
    t.integer "player_id"
    t.integer "eligible_games", default: 0, null: false
    t.boolean "is_total", default: true, null: false
    t.index ["roster_id", "name", "season", "team_id"], name: "pitchstat_ndx", unique: true
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "check_names", default: false, null: false
    t.boolean "names_fixed", default: false, null: false
    t.string "end_name"
    t.index ["buster_id"], name: "player_ndx", unique: true
    t.index ["player_type"], name: "player_type_ndx"
  end

  create_table "real_batting_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "player_id", default: 0
    t.string "abbrev", limit: 3
    t.string "injury", limit: 10
    t.string "stl", limit: 10
    t.string "run", limit: 10
    t.string "pos_c", limit: 10
    t.string "pos_1b", limit: 10
    t.string "pos_2b", limit: 10
    t.string "pos_3b", limit: 10
    t.string "pos_ss", limit: 10
    t.string "pos_lf", limit: 10
    t.string "pos_rf", limit: 10
    t.string "pos_cf", limit: 10
    t.string "cthr", limit: 10
    t.string "othr", limit: 10
    t.index ["season", "first_name", "last_name", "position", "age"], name: "rbs_ndx", unique: true
  end

  create_table "real_pitching_stats", force: :cascade do |t|
    t.integer "roster_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "player_id", default: 0
    t.string "abbrev", limit: 3
    t.string "injury", limit: 10
    t.string "rdur", limit: 10
    t.string "sdur", limit: 10
    t.index ["season", "first_name", "last_name", "position", "age"], name: "rps_ndx", unique: true
  end

  create_table "records", force: :cascade do |t|
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
    t.boolean "final_season_record", default: false, null: false
    t.float "league_gb"
    t.float "overall_gb"
    t.string "last_ten", array: true
    t.jsonb "wl_groups"
    t.jsonb "records_by_opponent"
    t.index ["season", "team_id"], name: "record_ndx", unique: true
  end

  create_table "rosters", force: :cascade do |t|
    t.integer "player_id", limit: 2
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "name", limit: 255, default: "", null: false
    t.string "end_name", limit: 255, default: "", null: false
    t.integer "age", limit: 2, null: false
    t.string "position", limit: 3, default: "", null: false
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
    t.integer "original_roster_id"
    t.boolean "is_pitcher", default: false, null: false
    t.index ["name", "position", "age", "season", "team_id"], name: "roster_ndx", unique: true
  end

  create_table "stat_sheets", force: :cascade do |t|
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "sheet_data"
    t.integer "sheet_size"
    t.string "sheet_signature"
    t.index ["owner_id"], name: "index_stat_sheets_on_owner_id"
    t.index ["sheet_signature"], name: "sheet_signature_ndx", unique: true
  end

  create_table "svg_images", force: :cascade do |t|
    t.integer "logoable_id"
    t.string "logoable_type"
    t.string "label"
    t.text "svgdata"
    t.index ["logoable_id", "logoable_type"], name: "logoable_ndx", unique: true
  end

  create_table "team_batting_stats", force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.integer "g"
    t.float "avg"
    t.float "obp"
    t.float "spc"
    t.integer "ab"
    t.integer "h"
    t.integer "h1b"
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
    t.index ["season", "team_id"], name: "team_batstat_ndx", unique: true
  end

  create_table "team_games", force: :cascade do |t|
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
    t.integer "game_id", default: 0, null: false
    t.index ["date"], name: "game_date_ndx"
    t.index ["game_id", "home"], name: "teamgame_game_ndx", unique: true
    t.index ["season"], name: "game_season_ndx"
    t.index ["team_id", "opponent_id", "win"], name: "team_win_ndx"
  end

  create_table "team_pitching_stats", force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
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
    t.index ["season", "team_id"], name: "team_pitchstat_ndx", unique: true
  end

  create_table "team_seasons", force: :cascade do |t|
    t.integer "season", limit: 2, null: false
    t.integer "team_id", limit: 2, null: false
    t.string "abbrev", limit: 3, default: "", null: false
    t.integer "owner_id", limit: 2, null: false
    t.string "league", limit: 10, default: "", null: false
    t.string "division", limit: 4, default: "", null: false
    t.integer "web_team_id", limit: 2
    t.boolean "div_win", default: false, null: false
    t.boolean "lcs_win", default: false, null: false
    t.boolean "ws_win", default: false, null: false
    t.index ["season", "team_id"], name: "ts_ndx", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.integer "owner_id"
    t.string "name", limit: 255, default: "", null: false
    t.string "abbrev", limit: 3, default: "", null: false
    t.string "league", limit: 10, default: "", null: false
    t.string "division", limit: 4, default: "", null: false
    t.integer "web_team_id", limit: 2
    t.integer "web_team_id_nn", limit: 2
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
    t.index ["name", "team_id"], name: "name_team_ndx"
  end

  create_table "uploads", force: :cascade do |t|
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "season", default: 0, null: false
    t.jsonb "archive_data"
    t.integer "archive_size"
    t.string "archive_signature"
    t.string "state"
    t.index ["archive_signature"], name: "archve_signature_ndx", unique: true
    t.index ["owner_id"], name: "index_uploads_on_owner_id"
  end

  add_foreign_key "batting_stats", "players"
  add_foreign_key "batting_stats", "rosters"
  add_foreign_key "boxscores", "games"
  add_foreign_key "game_batting_stats", "boxscores"
  add_foreign_key "game_batting_stats", "games"
  add_foreign_key "game_batting_stats", "players"
  add_foreign_key "game_batting_stats", "rosters"
  add_foreign_key "game_pitching_stats", "boxscores"
  add_foreign_key "game_pitching_stats", "games"
  add_foreign_key "game_pitching_stats", "players"
  add_foreign_key "game_pitching_stats", "rosters"
  add_foreign_key "games", "teams", column: "away_team_id"
  add_foreign_key "games", "teams", column: "home_team_id"
  add_foreign_key "innings", "boxscores"
  add_foreign_key "innings", "games"
  add_foreign_key "pitching_stats", "players"
  add_foreign_key "pitching_stats", "rosters"
  add_foreign_key "rosters", "players"
  add_foreign_key "rosters", "teams"
  add_foreign_key "team_batting_stats", "teams"
  add_foreign_key "team_games", "teams"
  add_foreign_key "team_games", "teams", column: "opponent_id"
  add_foreign_key "team_pitching_stats", "teams"
  add_foreign_key "team_seasons", "teams"
  add_foreign_key "transaction_logs", "teams"
end
