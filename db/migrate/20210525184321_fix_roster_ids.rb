class FixRosterIds < ActiveRecord::Migration[6.1]
  def change
    change_column :batter_playing_times, :roster_id, :int
    change_column :batting_stats, :roster_id, :int
    change_column :draft_batting_statlines, :roster_id, :int
    change_column :draft_pitching_statlines, :roster_id, :int
    change_column :game_batting_stats, :roster_id, :int
    change_column :game_pitching_stats, :roster_id, :int
    change_column :pitcher_playing_times, :roster_id, :int
    change_column :pitching_stats, :roster_id, :int
    change_column :real_batting_stats, :roster_id, :int
    change_column :real_pitching_stats, :roster_id, :int
  end
end
