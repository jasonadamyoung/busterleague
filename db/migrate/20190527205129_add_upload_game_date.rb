class AddUploadGameDate < ActiveRecord::Migration[5.2]
  def change
    add_column(:uploads, :latest_game_date, :datetime)
  end
end
