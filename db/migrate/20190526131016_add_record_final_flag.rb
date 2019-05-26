class AddRecordFinalFlag < ActiveRecord::Migration[5.2]
  def change
    add_column(:records, :final_season_record, :boolean, default: false, null: false)
  end
end
