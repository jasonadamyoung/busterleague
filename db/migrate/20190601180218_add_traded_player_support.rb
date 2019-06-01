class AddTradedPlayerSupport < ActiveRecord::Migration[5.2]
  def change
    add_column(:batting_stats, :age, :integer)
    add_column(:batting_stats, :player_id, :integer)
    add_column(:pitching_stats, :age, :integer)
    add_column(:pitching_stats, :player_id, :integer)
    execute "UPDATE batting_stats SET age = rosters.age,player_id = rosters.player_id FROM rosters  WHERE batting_stats.roster_id = rosters.id"
    execute "UPDATE pitching_stats SET age = rosters.age,player_id = rosters.player_id FROM rosters  WHERE pitching_stats.roster_id = rosters.id"
  end
end
