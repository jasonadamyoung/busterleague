class AddVariousForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :batting_stats, :players, validate: false
    add_foreign_key :batting_stats, :rosters, validate: false
    add_foreign_key :pitching_stats, :players, validate: false
    add_foreign_key :pitching_stats, :rosters, validate: false

    add_foreign_key :boxscores, :games, validate: false
    add_foreign_key :games, :teams, column: :home_team_id, validate: false
    add_foreign_key :games, :teams, column: :away_team_id, validate: false
    add_foreign_key :team_games, :teams, validate: false
    add_foreign_key :team_games, :teams, column: :opponent_id, validate: false
    add_foreign_key :team_pitching_stats, :teams, validate: false
    add_foreign_key :team_batting_stats,  :teams, validate: false
    add_foreign_key :team_seasons,  :teams, validate: false
    add_foreign_key :transaction_logs,  :teams, validate: false
  end
end
