class DropStatForeignKeys < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :batting_stats, :rosters
    remove_foreign_key :pitching_stats, :rosters
  end
end
