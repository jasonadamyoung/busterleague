class AddBoxscoreProcessedFlag < ActiveRecord::Migration[5.2]
  def change
    add_column(:boxscores, :data_records_created, :boolean, default: false, null: false)
    execute "UPDATE boxscores SET data_records_created = 't'"
  end
end
