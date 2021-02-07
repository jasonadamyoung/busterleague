class AddDmb2020DraftPicks < ActiveRecord::Migration[5.2]
  def up
    @season = 2020
    # create draft picks
    DraftPosition.create(team: Team.where(abbrev: 'DET').first, position: 1, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'PIT').first, position: 2, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'KC').first, position: 3, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'NYM').first, position: 4, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'CHC').first, position: 5, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'STL').first, position: 6, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'CWS').first, position: 7, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'SEA').first, position: 8, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'HOU').first, position: 9, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'NYY').first, position: 10, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'TEX').first, position: 11, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'CIN').first, position: 12, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'LA').first, position: 13, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'BOS').first, position: 14, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'PHI').first, position: 15, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'BAL').first, position: 16, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'ATL').first, position: 17, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'CLE').first, position: 18, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'SF').first, position: 19, season: @season)
    DraftPosition.create(team: Team.where(abbrev: 'OAK').first, position: 20, season: @season)

    # draft positions
    all_teams = DraftPosition.where(season: @season).order('position ASC').map{|p| p.team_id}

    # snake rounds
    all_teams_reverse = all_teams.reverse
    total_rounds = 25
    total_teams = all_teams.count
    for round in (1..total_rounds)
      for position_in_round in (1..total_teams)
        if(round.odd?)
          current_team_id = all_teams[position_in_round-1]
        else
          current_team_id = all_teams_reverse[position_in_round-1]
        end
        overallpick = ((round-1)*total_teams)+position_in_round
        DraftPick.create(season: @season, team_id: current_team_id, round: round, roundpick: position_in_round, overallpick: overallpick)
      end
    end
  end
end
