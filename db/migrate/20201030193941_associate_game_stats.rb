class AssociateGameStats < ActiveRecord::Migration[5.2]
  def change
    add_column(:game_batting_stats,:game_id,:integer)
    add_column(:game_batting_stats,:player_id,:integer)
    add_column(:game_pitching_stats,:game_id,:integer)
    add_column(:game_pitching_stats,:player_id,:integer)

    add_foreign_key :game_batting_stats, :boxscores, validate: false
    add_foreign_key :game_batting_stats, :rosters, validate: false
    add_foreign_key :game_batting_stats, :games, validate: false
    add_foreign_key :game_batting_stats, :players, validate: false

    add_foreign_key :game_pitching_stats, :boxscores, validate: false
    add_foreign_key :game_pitching_stats, :rosters, validate: false
    add_foreign_key :game_pitching_stats, :games, validate: false
    add_foreign_key :game_pitching_stats, :players, validate: false

    execute "UPDATE game_batting_stats SET game_id = boxscores.game_id FROM boxscores WHERE game_batting_stats.boxscore_id = boxscores.id"
    execute "UPDATE game_batting_stats SET player_id = rosters.player_id FROM rosters WHERE game_batting_stats.roster_id = rosters.id"
    execute "UPDATE game_pitching_stats SET game_id = boxscores.game_id FROM boxscores WHERE game_pitching_stats.boxscore_id = boxscores.id"
    execute "UPDATE game_pitching_stats SET player_id = rosters.player_id FROM rosters WHERE game_pitching_stats.roster_id = rosters.id"

    add_column(:innings,:game_id,:integer)
    add_foreign_key :innings, :boxscores, validate: false
    add_foreign_key :innings, :games, validate: false
    execute "UPDATE innings SET game_id = boxscores.game_id FROM boxscores WHERE innings.boxscore_id = boxscores.id"

  end
end
