class AddGameSingles < ActiveRecord::Migration[5.2]
  def change
    remove_column(:game_batting_stats, :created_at, :datetime)
    remove_column(:game_batting_stats, :updated_at, :datetime)
    add_column(:game_batting_stats, '1b', :integer, default: 0, null: false)
  end
end
