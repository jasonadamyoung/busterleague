class AddOwnerPositionPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table "draft_owner_position_prefs", id: :integer, force: :cascade do |t|
      t.integer "owner_id", default: 0, null: false
      t.integer "prefable_id", null: false
      t.string  "prefable_type", null: false
      t.integer "player_type", null: false
      t.string  "position", limit: 10, null: false, default: 'default'
      t.timestamps
      t.index ["owner_id","prefable_type","position","player_type"], name: "draft_owner_position_pref_ndx", unique: true
      t.index ["owner_id","prefable_id","prefable_type","player_type"], name: "dopp_reference_ndx"

    end
  end
end
