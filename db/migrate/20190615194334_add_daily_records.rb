class AddDailyRecords < ActiveRecord::Migration[5.2]
  def change

    Record.dump_data
    remove_column(:records, 'date')
    remove_index "records", name: "record_ndx"
    add_index "records", ["season", "team_id"], name: "record_ndx", unique: true 
    # rebuild overall records
    Game.available_seasons.each do |season|
      Record.create_or_update_season_records(season)
    end
    Record.create_or_update_season_records('all')



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

  end
end
