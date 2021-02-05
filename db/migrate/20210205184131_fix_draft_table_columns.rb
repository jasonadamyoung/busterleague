class FixDraftTableColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column(:draft_rankings, "ranking_value_id", "draft_ranking_value_id")
    rename_column(:draft_rankings, "player_id", "draft_player_id")
    rename_column(:draft_picks, "player_id", "draft_player_id")
    rename_column(:draft_wanteds, "player_id", "draft_player_id")
    rename_column(:draft_players, "lastname", "last_name")
    rename_column(:draft_players, "firstname", "first_name")
    rename_column(:owners, "lastname", "last_name")
    rename_column(:owners, "firstname", "first_name")
  end
end
