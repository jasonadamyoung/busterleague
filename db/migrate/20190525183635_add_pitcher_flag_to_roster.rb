class AddPitcherFlagToRoster < ActiveRecord::Migration[5.2]
  def change
    add_column(:rosters, :is_pitcher, :boolean, default: false, null: false)
  end
end
