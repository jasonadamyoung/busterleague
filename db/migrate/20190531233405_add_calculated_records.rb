class AddCalculatedRecords < ActiveRecord::Migration[5.2]
  def change
    add_column(:records, :last_ten, :string, array: true)
    add_column(:records, :wl_groups, :jsonb)
    add_column(:records, :records_by_opponent, :jsonb)
  end
end
