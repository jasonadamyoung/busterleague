class ModifyStats < ActiveRecord::Migration[5.2]
  def change
    rename_column(:batting_stats, :player_id, :roster_id)
    rename_column(:game_batting_stats, :player_id, :roster_id)
    rename_column(:game_pitching_stats, :player_id, :roster_id)

    remove_column(:batting_stats, :age)
    execute 'ALTER TABLE "batting_stats" ALTER COLUMN "roster_id" SET NOT NULL;'
    remove_index "batting_stats", name: "batstat_ndx"
    add_index "batting_stats", ["roster_id", "name","season","team_id"], name: "batstat_ndx", unique: true 
  end
end
