class FixPositionCase < ActiveRecord::Migration[5.2]
  def up
    execute("UPDATE draft_players SET position = LOWER(position) WHERE TRUE;")
  end
end
