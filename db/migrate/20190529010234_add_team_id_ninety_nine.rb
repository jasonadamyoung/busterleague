class AddTeamIdNinetyNine < ActiveRecord::Migration[5.2]
  def change
    add_column(:teams, :web_team_id_nn, :integer, limit: 2)
    execute "UPDATE teams SET web_team_id_nn = 16 WHERE id = 1;"
    execute "UPDATE teams SET web_team_id_nn = 23 WHERE id = 2;"
    execute "UPDATE teams SET web_team_id_nn = 35 WHERE id = 3;"
    execute "UPDATE teams SET web_team_id_nn = 19 WHERE id = 4;"
    execute "UPDATE teams SET web_team_id_nn = 7 WHERE id = 5;"
    execute "UPDATE teams SET web_team_id_nn = 14 WHERE id = 6;"
    execute "UPDATE teams SET web_team_id_nn = 22 WHERE id = 7;"
    execute "UPDATE teams SET web_team_id_nn = 4 WHERE id = 8;"
    execute "UPDATE teams SET web_team_id_nn = 6 WHERE id = 9;"
    execute "UPDATE teams SET web_team_id_nn = 18 WHERE id = 10;"
    execute "UPDATE teams SET web_team_id_nn = 21 WHERE id = 11;"
    execute "UPDATE teams SET web_team_id_nn = 12 WHERE id = 12;"
    execute "UPDATE teams SET web_team_id_nn = 25 WHERE id = 13;"
    execute "UPDATE teams SET web_team_id_nn = 13 WHERE id = 14;"
    execute "UPDATE teams SET web_team_id_nn = 11 WHERE id = 15;"
    execute "UPDATE teams SET web_team_id_nn = 31 WHERE id = 16;"
    execute "UPDATE teams SET web_team_id_nn = 5 WHERE id = 17;"
    execute "UPDATE teams SET web_team_id_nn = 36 WHERE id = 18;"
    execute "UPDATE teams SET web_team_id_nn = 1 WHERE id = 19;"
    execute "UPDATE teams SET web_team_id_nn = 30 WHERE id = 20;"
  end
end
