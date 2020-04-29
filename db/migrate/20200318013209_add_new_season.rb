class AddNewSeason < ActiveRecord::Migration[5.2]
  def up
    execute("ALTER SEQUENCE team_seasons_id_seq RESTART with 401;")
    Team.all.each do |t|
      TeamSeason.create_for_season_and_team(2019,t)
    end
  end
end
