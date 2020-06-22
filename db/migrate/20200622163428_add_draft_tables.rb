class AddDraftTables < ActiveRecord::Migration[5.2]
  def change

    create_table "draft_picks", id: :integer, force: :cascade do |t|
      t.integer "season", limit: 2, null: false
      t.integer "team_id", default: 0, null: false
      t.integer "player_id", default: 0
      t.boolean "traded", default: false
      t.integer "original_team_id", default: 0
      t.integer "round", default: 0
      t.integer "roundpick", default: 0
      t.integer "overallpick", default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "draft_positions", id: :integer, force: :cascade do |t|
      t.integer "season", limit: 2, null: false
      t.integer "position"
      t.integer "team_id"
      t.index ["team_id", "season"], name: "draft_pos_season_team_ndx"
    end

    create_table "draft_ranking_values", id: :integer, force: :cascade do |t|
      t.string "label"
      t.integer "owner_id", default: 1
      t.integer "playertype", default: 1
      t.text "formula"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "draft_rankings", id: :integer, force: :cascade do |t|
      t.integer "ranking_value_id", default: 0
      t.integer "player_id", default: 0
      t.float "value", default: 0.0
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["ranking_value_id", "player_id"], name: "rv_player", unique: true
      t.index ["value"], name: "by_value"
    end

    create_table "draft_stat_preferences", id: :integer, force: :cascade do |t|
      t.string "label"
      t.integer "owner_id", default: 1
      t.integer "playertype", default: 1
      t.text "column_list"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["owner_id", "playertype"], name: "draft_sp_ndx"
    end

    create_table "draft_wanteds", id: :integer, force: :cascade do |t|
      t.integer "owner_id", default: 1
      t.integer "player_id", default: 0
      t.text "notes"
      t.string "highlight", default: "ffff00"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["owner_id", "player_id"], name: "draft_wanted_ndx", unique: true
    end




  end
end
