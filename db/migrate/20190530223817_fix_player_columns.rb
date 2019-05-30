class FixPlayerColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column(:players, :teams)
    remove_column(:players, :seasons)
    remove_column(:players, :positions)
  end
end
