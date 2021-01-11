class AddPlayerTypeIndex < ActiveRecord::Migration[5.2]
  def change
    add_index "players", ["player_type"], name: "player_type_ndx"
  end
end
