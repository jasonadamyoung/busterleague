class AddGamesToBs < ActiveRecord::Migration[5.2]
  def change
    add_column(:batting_stats, :g, :integer)
  end
end
