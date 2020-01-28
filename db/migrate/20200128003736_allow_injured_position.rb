class AllowInjuredPosition < ActiveRecord::Migration[5.2]
  def change
    change_column(:real_batting_stats, :position, :string, limit: 3)
    change_column(:real_pitching_stats, :position, :string, limit: 3)
    change_column(:batting_stats, :position, :string, limit: 3)
    change_column(:pitching_stats, :position, :string, limit: 3)
    change_column(:rosters, :position, :string, limit: 3)
  end
end
