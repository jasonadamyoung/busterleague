class AddUploadSeason < ActiveRecord::Migration[5.2]
  def change
    add_column(:uploads, :season, :integer, default: 0, null: false)
  end
end
