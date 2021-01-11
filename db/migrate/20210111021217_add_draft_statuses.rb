class AddDraftStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table "draft_statuses", force: :cascade do |t|
      t.integer "season"
      t.references :player
      t.integer "draft_status"
      t.integer "draft_team_id", default: 0, null: false
      t.integer "roster_id"
      t.index ["season","player_id","draft_status","draft_team_id"], name: "draft_player_ndx"
    end
  end
end
