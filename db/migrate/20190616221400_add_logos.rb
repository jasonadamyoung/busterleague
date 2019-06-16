class AddLogos < ActiveRecord::Migration[5.2]
  def up
    create_table "svg_images", force: :cascade do |t|
      t.integer "logoable_id"
      t.string "logoable_type"
      t.string "label"
      t.text   "svgdata"
      t.index ["logoable_id", "logoable_type"], name: "logoable_ndx", unique: true
    end

    execute "INSERT INTO svg_images(logoable_id,logoable_type,label,svgdata) SELECT id, 'Team', name, svglogo FROM teams;"
    remove_column(:teams, :svglogo)
  end

  def down
    drop_table(:logos)
  end


end
