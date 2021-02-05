class AddDraftStatDistributions < ActiveRecord::Migration[5.2]
  def change
    create_table "draft_stat_distributions", id: :integer, force: :cascade do |t|
      t.references :defined_stat
      t.integer "player_type", default: 1
      t.string "label"
      t.string "name"
      t.float "mean"
      t.float "max"
      t.float "min"
      t.float "median"
      t.float "range"
      t.text "distribution"
      t.text "scaled_distribution"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
