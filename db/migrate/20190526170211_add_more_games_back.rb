class AddMoreGamesBack < ActiveRecord::Migration[5.2]
  def change
    add_column(:records, :league_gb, :float)
    add_column(:records, :overall_gb, :float)
  end
end
