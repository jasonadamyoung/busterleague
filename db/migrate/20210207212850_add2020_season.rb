class Add2020Season < ActiveRecord::Migration[5.2]
  def up
    execute("ALTER SEQUENCE team_seasons_id_seq RESTART with 421;")
    Team.all.each do |t|
      TeamSeason.create_for_season_and_team(2020,t)
    end
  end
end
