class FixStatIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index "real_batting_stats", name: "rbs_roster_ndx"
    add_index "real_batting_stats", ["season", "first_name","last_name","position","age"], name: "rbs_ndx", unique: true
    remove_index "real_pitching_stats", name: "rps_roster_ndx"
    add_index "real_pitching_stats", ["season", "first_name","last_name","position","age"], name: "rps_ndx", unique: true
  end
end
