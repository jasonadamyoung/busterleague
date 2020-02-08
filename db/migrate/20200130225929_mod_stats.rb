class ModStats < ActiveRecord::Migration[5.2]
  def change
    # modify real batting stats with quality values
    add_column(:real_batting_stats,:injury,:string, limit: 10)
    add_column(:real_batting_stats,:stl,:string, limit: 10)
    add_column(:real_batting_stats,:run,:string, limit: 10)
    add_column(:real_batting_stats,:pos_c,:string, limit: 10)
    add_column(:real_batting_stats,:pos_1b,:string, limit: 10)
    add_column(:real_batting_stats,:pos_2b,:string, limit: 10)
    add_column(:real_batting_stats,:pos_3b,:string, limit: 10)
    add_column(:real_batting_stats,:pos_ss,:string, limit: 10)
    add_column(:real_batting_stats,:pos_lf,:string, limit: 10)
    add_column(:real_batting_stats,:pos_rf,:string, limit: 10)
    add_column(:real_batting_stats,:pos_cf,:string, limit: 10)
    add_column(:real_batting_stats,:cthr,:string, limit: 10)
    add_column(:real_batting_stats,:othr,:string, limit: 10)

    # modify real pitching stats with quality values
    add_column(:real_batting_stats,:injury,:string, limit: 10)
    add_column(:real_batting_stats,:rdur,:string, limit: 10)
    add_column(:real_batting_stats,:sdur,:string, limit: 10)
  end
end
