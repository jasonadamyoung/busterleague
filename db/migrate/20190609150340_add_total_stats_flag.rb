class AddTotalStatsFlag < ActiveRecord::Migration[5.2]
  def up
    add_column(:batting_stats, :eligible_games, :integer, default: 0, null: false)
    add_column(:batting_stats, :is_total, :boolean, default: true, null: false)
    BattingStat.reset_column_information
    BattingStat.fix_total_flags
    execute "UPDATE batting_stats SET eligible_games = 162 WHERE season < 2018"
    Team.update_batting_stats_for_season(2018)

    add_column(:pitching_stats, :eligible_games, :integer, default: 0, null: false)
    add_column(:pitching_stats, :is_total, :boolean, default: true, null: false)
    PitchingStat.reset_column_information
    PitchingStat.fix_total_flags
    execute "UPDATE pitching_stats SET eligible_games = 162 WHERE season < 2018"
    Team.update_pitching_stats_for_season(2018)

  end

  def down
    remove_column(:batting_stats, :eligible_games)
    remove_column(:pitching_stats, :eligible_games)
    remove_column(:batting_stats, :is_total)
    remove_column(:pitching_stats, :is_total)
  end
end
