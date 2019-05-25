class AddStatSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :stat_sheets do |t|
      t.references :owner
      t.attachment :datafile
      t.string :datafile_fingerprint
      t.timestamps
    end
  
    add_index "stat_sheets", ["datafile_fingerprint"], name: "statsheet_fingerprint_ndx", unique: true
  end
end
