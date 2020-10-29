class AddPlayerSeasons < ActiveRecord::Migration[5.2]
  def change
    create_table "player_seasons", force: :cascade do |t|
      t.integer    :season
      t.references :player, foreign_key: true
      t.references :team, foreign_key: true
      t.references :roster, foreign_key: true
    end

  end
end
