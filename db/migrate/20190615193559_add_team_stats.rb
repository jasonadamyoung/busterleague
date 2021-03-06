class AddTeamStats < ActiveRecord::Migration[5.2]
  def change
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

  end
end
