class AddStatLabel < ActiveRecord::Migration[5.2]
  def change
    add_column(:defined_stats, :display_label, :string)
  end
end
