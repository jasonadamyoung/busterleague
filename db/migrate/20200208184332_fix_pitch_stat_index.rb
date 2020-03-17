class FixPitchStatIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index "pitching_stats", name: "pitchstat_ndx"
    add_index "pitching_stats", ["roster_id", "name","season","team_id"], name: "pitchstat_ndx", unique: true
  end
end
