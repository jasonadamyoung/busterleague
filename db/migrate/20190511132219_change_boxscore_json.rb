class ChangeBoxscoreJson < ActiveRecord::Migration[5.2]
  def change
    remove_column(:boxscores, :home_team_stats, :jsonb)
    remove_column(:boxscores, :away_team_stats, :jsonb)
    remove_column(:boxscores, :home_batting_stats, :jsonb)
    remove_column(:boxscores, :home_pitching_stats, :jsonb)
    remove_column(:boxscores, :away_batting_stats, :jsonb)
    remove_column(:boxscores, :away_pitching_stats, :jsonb)
    add_column(:boxscores, :game_stats, :jsonb)


  end
end
