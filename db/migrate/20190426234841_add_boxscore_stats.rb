class AddBoxscoreStats < ActiveRecord::Migration[5.2]
  def change
    remove_column(:boxscores, :stats, :text)
    add_column(:boxscores, :home_team_stats, :jsonb)
    add_column(:boxscores, :away_team_stats, :jsonb)
    add_column(:boxscores, :home_batting_stats, :jsonb)
    add_column(:boxscores, :home_pitching_stats, :jsonb)
    add_column(:boxscores, :away_batting_stats, :jsonb)
    add_column(:boxscores, :away_pitching_stats, :jsonb)

  end
end
