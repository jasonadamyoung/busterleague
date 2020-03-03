class AllowNullRealTeams < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:real_batting_stats, :team_id, true)
    change_column_null(:real_pitching_stats, :team_id, true)
  end
end
