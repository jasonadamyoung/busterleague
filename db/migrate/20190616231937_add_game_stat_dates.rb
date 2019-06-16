class AddGameStatDates < ActiveRecord::Migration[5.2]
  def up
    add_column(:game_batting_stats, :date, :date)
    add_column(:game_pitching_stats, :date, :date)

    execute "UPDATE game_batting_stats SET date = boxscores.date FROM boxscores  WHERE game_batting_stats.boxscore_id = boxscores.id"
    execute "UPDATE game_pitching_stats SET date = boxscores.date FROM boxscores  WHERE game_pitching_stats.boxscore_id = boxscores.id"
  end

  def down
    remove_column(:game_batting_stats, :date)
    remove_column(:game_pitching_stats, :date)
  end
end
