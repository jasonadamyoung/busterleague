class CleanupUploadColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column(:uploads, :processing_status, :integer)
    remove_column(:uploads, :rebuild_id, :integer)
    remove_column(:uploads, :latest_game_date, :datetime)
    remove_column(:uploads, :archive_updated_at, :datetime)
  end
end
