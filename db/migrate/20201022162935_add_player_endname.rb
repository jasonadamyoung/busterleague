class AddPlayerEndname < ActiveRecord::Migration[5.2]
  def change
    add_column(:players,:end_name,:string)
  end
end
