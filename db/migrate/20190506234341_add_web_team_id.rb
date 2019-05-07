class AddWebTeamId < ActiveRecord::Migration[5.2]
  def change
    add_column(:teams, :web_team_id, :integer, limit: 2)
  end
end
