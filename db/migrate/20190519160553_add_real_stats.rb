class AddRealStats < ActiveRecord::Migration[5.2]
  def change
    create_table "real_batting_stats", force: :cascade do |t|
      t.integer   "roster_id",   limit: 2
      t.integer   "season",      limit: 2, null: false
      t.integer   "team_id",     limit: 2, null: false
      t.string    "first_name",        limit: 255, default: "", null: false
      t.string    "last_name",        limit: 255, default: "", null: false
      t.string    "position",    limit: 2,   default: "", null: false
      t.integer   "age",         limit: 2, null: false
      t.string    "bats",    limit: 2,   default: "", null: false
      t.float     "avg"        
      t.float     "obp"
      t.float     "spc"
      t.integer   "pa"
      t.integer   "ab"
      t.integer   "hr"
      t.integer   "r"
      t.integer   "rbi"
      t.integer   "bb"
      t.integer   "k"
      t.integer   "sb"
      t.integer   "gs"
      t.float     "ops"
      t.float     "rc"
      t.float     "rc27"
      t.float     "iso"
      t.integer   "ebh"
      t.integer   "tb"
      t.float     "babip"
      t.float     "woba"
      t.integer   "wrcplus"
      t.float     "war_fg"
      t.float     "opsplus"
      t.float     "war_br"
      t.float     "l_avg"        
      t.float     "l_obp"
      t.float     "l_spc"
      t.float     "l_ops"
      t.integer   "l_pa"
      t.float     "r_avg"        
      t.float     "r_obp"
      t.float     "r_spc"
      t.float     "r_ops"
      t.integer   "r_pa"
    end

    add_index "real_batting_stats", ["roster_id"], name: "rbs_roster_ndx", unique: true


    create_table "real_pitching_stats", force: :cascade do |t|
      t.integer   "roster_id",   limit: 2
      t.integer   "season",      limit: 2, null: false
      t.integer   "team_id",     limit: 2, null: false
      t.string    "first_name",        limit: 255, default: "", null: false
      t.string    "last_name",        limit: 255, default: "", null: false
      t.string    "position",    limit: 2,   default: "", null: false
      t.integer   "age",         limit: 2, null: false
      t.string    "throws",    limit: 2,   default: "", null: false
      t.float     "era"
      t.integer   "w"
      t.integer   "l"
      t.integer   "s"
      t.integer   "g"
      t.integer   "gs"
      t.float     "ip"
      t.integer   "k"
      t.float     "avg"
      t.float     "obp"
      t.float     "spc"
      t.float     "ops"
      t.float     "rc"
      t.float     "rc27"
      t.float     "rcera"
      t.float     "cera"
      t.integer   "eraplus"
      t.float     "whip"
      t.float     "h_per_9"
      t.float     "k_per_9"
      t.float     "bb_per_9"
      t.float     "hr_per_9"
      t.float     "k_per_bb"
      t.float     "babip"
      t.float     "fip"
      t.float     "xfip"
      t.float     "war_fg"
      t.float     "war_br"
      t.float     "l_avg"        
      t.float     "l_obp"
      t.float     "l_spc"
      t.float     "l_ops"
      t.integer   "l_pa"
      t.float     "r_avg"        
      t.float     "r_obp"
      t.float     "r_spc"
      t.float     "r_ops"
      t.integer   "r_pa"
    end
    
    add_index "real_pitching_stats", ["roster_id"], name: "rps_roster_ndx", unique: true

  end
end
