class ChangeStats < ActiveRecord::Migration[5.2]
  def change
    add_column(:game_batting_stats, "lineup", :integer, default: 0, null: false)
    rename_column(:game_batting_stats, '1b', 'h1b')
    rename_column(:game_batting_stats, '2b', 'h2b')
    rename_column(:game_batting_stats, '3b', 'h3b')

    rename_column(:batting_stats, '2b', 'h2b')
    rename_column(:batting_stats, '3b', 'h3b')
    add_column(:batting_stats, 'h1b', :integer, default: 0, null: false)

    remove_column(:game_pitching_stats, :created_at, :datetime)
    remove_column(:game_pitching_stats, :updated_at, :datetime)

  end
end
