class AddBattingStats < ActiveRecord::Migration[5.2]
  def change

    create_table "batting_stats", force: :cascade do |t|
      t.integer   "player_id",   limit: 2
      t.integer   "season",      limit: 2, null: false
      t.integer   "team_id",     limit: 2, null: false
      t.string    "name",        limit: 255, default: "", null: false
      t.string    "flag",        limit: 1,   default: "", null: false
      t.string    "position",    limit: 2,   default: "", null: false
      t.integer   "age",         limit: 2, null: false
      t.float     "avg"        
      t.float     "obp"
      t.float     "spc"
      t.integer   "ab"
      t.integer   "h"
      t.integer   "2b"
      t.integer   "3b"
      t.integer   "hr"
      t.integer   "r"
      t.integer   "rbi"
      t.integer   "hbp"
      t.integer   "bb"
      t.integer   "k"
      t.integer   "sb"
      t.integer   "cs"
      t.integer   "gs"
      t.integer   "pa"
      t.integer   "sh"
      t.integer   "sf"
      t.integer   "gdp"
      t.float     "ops"
      t.float     "rc"
      t.float     "rc27"
      t.float     "iso"
      t.float     "tavg"
      t.float     "sec"
      t.integer   "ebh"
      t.integer   "tb"
      t.float     "pa_per_g"
      t.float     "ab_per_g"
      t.integer   "bip"
      t.float     "ipavg"
      t.integer   "tbw"
      t.float     "tbw_per_pa"
      t.integer   "tbwh"
      t.float     "tbwh_per_pa"
      t.float     "k_per_bb"
      t.float     "l_avg"        
      t.float     "l_obp"
      t.float     "l_spc"
      t.float     "l_ops"
      t.integer   "l_ab"
      t.integer   "l_h"
      t.integer   "l_2b"
      t.integer   "l_3b"
      t.integer   "l_hr"
      t.integer   "l_rbi"
      t.integer   "l_bb"
      t.integer   "l_k"
      t.float     "r_avg"        
      t.float     "r_obp"
      t.float     "r_spc"
      t.float     "r_ops"
      t.integer   "r_ab"
      t.integer   "r_h"
      t.integer   "r_2b"
      t.integer   "r_3b"
      t.integer   "r_hr"
      t.integer   "r_rbi"
      t.integer   "r_bb"
      t.integer   "r_k"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    add_index "batting_stats", ["name","season","team_id"], name: "batstat_ndx", unique: true




  end
end
