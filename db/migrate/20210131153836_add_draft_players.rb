class AddDraftPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table "draft_players", id: :integer, force: :cascade do |t|
      t.integer "season"
      t.references :player
      t.references :roster
      t.string "firstname", default: "", null: false
      t.string "lastname", default: "", null: false
      t.string "position", limit: 3, default: "", null: false
      t.integer "age", default: 0, null: false
      t.string "type", default: "0"
      t.integer "statline_id", default: 0
      t.integer "team_id", default: 0, null: false
      t.integer "original_team_id", default: 0, null: false
      t.integer "draftstatus", default: 2, null: false
      t.datetime "updated_at"
    end

    add_index "draft_players", ["draftstatus"], name: "draftplayers_draftstatus_ndx"
    add_index "draft_players", ["lastname", "firstname"], name: "draftplayers_name_ndx"
    add_index "draft_players", ["position"], name: "draftplayers_position_ndx"
    add_index "draft_players", ["statline_id"], name: "draftplayers_statline_ndx"
    add_index "draft_players", ["type"], name: "draftplayers_type_ndx"

  end
end
