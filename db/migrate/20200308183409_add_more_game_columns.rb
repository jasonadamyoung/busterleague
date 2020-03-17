class AddMoreGameColumns < ActiveRecord::Migration[5.2]
  def change
    add_column(:games, :home_hits, :integer)
    add_column(:games, :away_hits, :integer)
    add_column(:games, :home_errs, :integer)
    add_column(:games, :away_errs, :integer)
  end
end
