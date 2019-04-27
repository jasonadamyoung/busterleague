class AddBoxscoreStats < ActiveRecord::Migration[5.2]
  def change
    create_table "boxstats", force: :cascade do |t|
      t.integer "boxscore_id",   limit: 4
      t.integer "home_runs",       limit: 4
      t.integer "away_runs",       limit: 4
      t.integer "total_innings",   limit: 4
      t.jsonb  "home_team"
      t.jsonb  "away_team"
      t.jsonb  "home_batting"
      t.jsonb  "home_pitching"
      t.jsonb  "away_batting"
      t.jsonb  "away_pitching"
    end

    add_index "boxstats", ["boxscore_id"], name: "boxstat_boxscore_ndx", unique: true

    remove_column(:boxscores, :stats, :text)
    remove_column(:boxscores, :home_runs, :integer)
    remove_column(:boxscores, :away_runs, :integer)
    remove_column(:boxscores, :total_innings, :integer)

  end
end
