class CleanupNameColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column(:rosters, :first_name, :string)
    remove_column(:rosters, :last_name, :string)

    remove_column(:batting_stats, :first_name, :string)
    remove_column(:batting_stats, :last_name, :string)

    remove_column(:pitching_stats, :first_name, :string)
    remove_column(:pitching_stats, :last_name, :string)

    remove_column(:game_batting_stats, :first_name, :string)
    remove_column(:game_batting_stats, :last_name, :string)

    remove_column(:game_pitching_stats, :first_name, :string)
    remove_column(:game_pitching_stats, :last_name, :string)

    remove_column(:transaction_logs, :first_name, :string)
    remove_column(:transaction_logs, :last_name, :string)
  end
end
