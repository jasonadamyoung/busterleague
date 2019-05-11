class AddWebTeamId < ActiveRecord::Migration[5.2]
  def change
    add_column(:teams, :web_team_id, :integer, limit: 2)
    execute "UPDATE teams SET web_team_id = 29 WHERE id = 1;"
    execute "UPDATE teams SET web_team_id = 7 WHERE id = 2;"
    execute "UPDATE teams SET web_team_id = 12 WHERE id = 3;"
    execute "UPDATE teams SET web_team_id = 1 WHERE id = 4;"
    execute "UPDATE teams SET web_team_id = 27 WHERE id = 5;"
    execute "UPDATE teams SET web_team_id = 24 WHERE id = 6;"
    execute "UPDATE teams SET web_team_id = 6 WHERE id = 7;"
    execute "UPDATE teams SET web_team_id = 19 WHERE id = 8;"
    execute "UPDATE teams SET web_team_id = 21 WHERE id = 9;"
    execute "UPDATE teams SET web_team_id = 0 WHERE id = 10;"
    execute "UPDATE teams SET web_team_id = 5 WHERE id = 11;"
    execute "UPDATE teams SET web_team_id = 18 WHERE id = 12;"
    execute "UPDATE teams SET web_team_id = 8 WHERE id = 13;"
    execute "UPDATE teams SET web_team_id = 23 WHERE id = 14;"
    execute "UPDATE teams SET web_team_id = 17 WHERE id = 15;"
    execute "UPDATE teams SET web_team_id = 11 WHERE id = 16;"
    execute "UPDATE teams SET web_team_id = 20 WHERE id = 17;"
    execute "UPDATE teams SET web_team_id = 13 WHERE id = 18;"
    execute "UPDATE teams SET web_team_id = 14 WHERE id = 19;"
    execute "UPDATE teams SET web_team_id = 2 WHERE id = 20;"
  end
end
