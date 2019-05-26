class AddNamingThings < ActiveRecord::Migration[5.2]
  def change
    add_column(:players, :check_names, :boolean, default: false, null: false)
    add_column(:players, :names_fixed, :boolean, default: false, null: false)
    add_column(:rosters, :first_name, :string)
    add_column(:rosters, :last_name, :string)
    add_column(:batting_stats, :first_name, :string)
    add_column(:batting_stats, :last_name, :string)
    add_column(:pitching_stats, :first_name, :string)
    add_column(:pitching_stats, :last_name, :string)
    add_column(:game_batting_stats, :first_name, :string)
    add_column(:game_batting_stats, :last_name, :string)
    add_column(:game_pitching_stats, :first_name, :string)
    add_column(:game_pitching_stats, :last_name, :string)
    add_column(:transaction_logs, :first_name, :string)
    add_column(:transaction_logs, :last_name, :string)
  end
end
