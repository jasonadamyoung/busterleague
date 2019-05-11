# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Record < ApplicationRecord
	belongs_to :team
  
  before_save :set_win_minus_losses

  scope :winners, -> { where("wins / games::float > .5") }
  scope :losers, -> { where("wins / games::float <= .5") }
  scope :on_date, lambda {|date| where("date = ?",date)}
  scope :on_season_date, lambda {|season,date| where(season: season).where("date = ?",date)}
  scope :for_season, lambda {|season| where(season: season)}

  def self.dump_data
    self.connection.execute("TRUNCATE table #{table_name} RESTART IDENTITY;")
  end
  
  def set_win_minus_losses
    self.wins_minus_losses = self.wins - self.losses
  end

  def self.create_or_update_records(season)
    for date in (Game.earliest_date(season)..Game.latest_date(season)) do
      Team.all.each do |team|
        record = self.create_or_update_for_team_and_date(season,team,date)
        # streak
        gameslist_through_season_date = team.games.through_season_date(season,date).order(:date)
        streak_code = ''
        streak_count = 0
        gameslist_through_season_date.each do |game|
          game_code = (game.win? ? 'W' : 'L')
          if(game_code == streak_code)
            streak_count += 1
          else
            streak_code = game_code
            streak_count = 1
          end
        end
        record.update_column(:streak, "#{streak_code}#{streak_count}")
      end

      # gamesback
      leagues = Team.group(:league).count(:league)
      leagues.keys.each do |league|
        divisions = Team.where(:league => league).group(:division).count(:division)
        divisions.keys.each do |division|
          teamlist = Team.where(:league => league).where(:division => division).load
          records = {}
          teamlist.each do |team|
            records[team] = team.records.on_season_date(season,date).first
          end

          maxwml = records.values.map(&:wins_minus_losses).max
          records.each do |team,record|
            record.update_column(:gb, (maxwml - record.wins_minus_losses) / 2.to_f)
          end
        end
      end


    end
  end

  def self.create_or_update_for_team_and_date(season,team,date)
    if(!record_for_date = self.where(season: season).where(:date => date).where(:team_id => team.id).first)
      record_for_date = Record.new(season: season, date: date, team: team)
    end

    record_for_date.home_games = team.games.home.through_season_date(season,date).count
    record_for_date.road_games = team.games.away.through_season_date(season,date).count
    record_for_date.games =  record_for_date.home_games + record_for_date.road_games
    record_for_date.wins = team.games.wins.through_season_date(season,date).count
    record_for_date.home_wins = team.games.home.wins.through_season_date(season,date).count
    record_for_date.road_wins = team.games.away.wins.through_season_date(season,date).count
    record_for_date.losses = record_for_date.games - record_for_date.wins
    record_for_date.home_rf = team.games.home.through_season_date(season,date).sum(:runs)
    record_for_date.home_ra = team.games.home.through_season_date(season,date).sum(:opponent_runs)
    record_for_date.road_rf = team.games.away.through_season_date(season,date).sum(:runs)
    record_for_date.road_ra = team.games.away.through_season_date(season,date).sum(:opponent_runs)
    record_for_date.rf = record_for_date.home_rf + record_for_date.road_rf
    record_for_date.ra = record_for_date.home_ra + record_for_date.road_ra
    record_for_date.save!
    record_for_date
  end

  def self.rebuild(season)
    self.create_or_update_records(season)
  end


end
