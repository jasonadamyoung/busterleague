class AddBoxscoreProcessedFlag < ActiveRecord::Migration[5.2]
  def change
    add_column(:boxscores, :data_records_created, :boolean, default: false, null: false)
  end
end
