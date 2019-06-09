class AddTotalStatsFlag < ActiveRecord::Migration[5.2]
  def up
    add_column(:batting_stats, :is_total, :boolean, default: true, null: false)
    BattingStat.reset_column_information
    BattingStat.fix_total_flags

    add_column(:pitching_stats, :is_total, :boolean, default: true, null: false)
    PitchingStat.reset_column_information
    PitchingStat.fix_total_flags
  end

  def down
    remove_column(:batting_stats, :is_total)
    remove_column(:pitching_stats, :is_total)
  end
end
