class AddRosterForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :rosters, :players
    add_foreign_key :rosters, :teams
  end
end
