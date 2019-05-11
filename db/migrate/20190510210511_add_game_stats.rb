class AddGameStats < ActiveRecord::Migration[5.2]
  def change

    create_table "game_batting_stats", force: :cascade do |t|
      t.integer   "boxscore_id", limit: 2
      t.integer   "player_id",   limit: 2
      t.integer   "season",      limit: 2, null: false
      t.integer   "team_id",     limit: 2, null: false
      t.integer   "opposing_team_id",     limit: 2, null: false
      t.integer   "location",    limit: 2, null: false
      t.string    "name",        limit: 255, default: "", null: false
      t.string    "position",    limit: 2,   default: "", null: false
      t.integer   "ab",          default: 0, null: false
      t.integer   "h",          default: 0, null: false
      t.integer   "2b",          default: 0, null: false
      t.integer   "3b",          default: 0, null: false
      t.integer   "hr",          default: 0, null: false
      t.integer   "r",          default: 0, null: false
      t.integer   "rbi",          default: 0, null: false
      t.integer   "hbp",          default: 0, null: false
      t.integer   "bb",          default: 0, null: false
      t.integer   "k",          default: 0, null: false
      t.integer   "sb",          default: 0, null: false
      t.integer   "cs",          default: 0, null: false
      t.integer   "gs",          default: 0, null: false
      t.integer   "pa",          default: 0, null: false
      t.integer   "sh",          default: 0, null: false
      t.integer   "sf",          default: 0, null: false
      t.integer   "gdp",          default: 0, null: false
      t.integer   "ebh",          default: 0, null: false
      t.integer   "tb",          default: 0, null: false
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    add_index "game_batting_stats", ["boxscore_id","name","team_id"], name: "gbs_ndx", unique: true

    create_table "game_pitching_stats", force: :cascade do |t|
      t.integer   "boxscore_id", limit: 2
      t.integer   "player_id",   limit: 2
      t.integer   "season",      limit: 2, null: false
      t.integer   "team_id",     limit: 2, null: false
      t.integer   "opposing_team_id",     limit: 2, null: false
      t.integer   "location",    limit: 2, null: false
      t.string    "name",        limit: 255, default: "", null: false
      t.integer   "w",          default: 0, null: false
      t.integer   "l",          default: 0, null: false
      t.integer   "hold",          default: 0, null: false
      t.integer   "s",          default: 0, null: false
      t.integer   "bs",          default: 0, null: false
      t.float     "ip",          default: 0.0, null: false
      t.integer   "h"
      t.integer   "r"
      t.integer   "er"
      t.integer   "bb"
      t.integer   "k"
      t.integer   "pch"
      t.integer   "str"
      t.integer   "hb"
      t.integer   "balk"
      t.integer   "wp"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    add_index "game_pitching_stats", ["boxscore_id","name","team_id"], name: "gps_ndx", unique: true

  end
end
