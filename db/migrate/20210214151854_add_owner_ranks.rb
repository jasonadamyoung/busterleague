class AddOwnerRanks < ActiveRecord::Migration[5.2]
  def change
    create_table "draft_owner_ranks", id: :integer, force: :cascade do |t|
      t.integer "owner_id", default: 0
      t.integer "draft_player_id", default: 0
      t.integer "overall", default: 9999
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["owner_id", "draft_player_id"], name: "draft_owner_rank_owner_player_ndx", unique: true
    end
  end
end
