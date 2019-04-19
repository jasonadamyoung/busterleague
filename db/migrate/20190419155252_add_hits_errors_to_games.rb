class AddHitsErrorsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column(:games, :hits, :integer)
    add_column(:games, :opponent_hits, :integer)
    add_column(:games, :errs, :integer)
    add_column(:games, :opponent_errs, :integer)
  end
end
