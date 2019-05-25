class AddOriginalRoster < ActiveRecord::Migration[5.2]
  def change
    add_column(:rosters, :original_roster_id, :integer)
  end
end
