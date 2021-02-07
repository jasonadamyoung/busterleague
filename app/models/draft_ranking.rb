# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftRanking < ApplicationRecord
  belongs_to :draft_player
  belongs_to :draft_ranking_value

  def self.create_or_update_from_ranking_value(draft_ranking_value)
    draft_ranking_value.rankings_distribution.each do |draft_player,rankvalue|
      if(ranking = self.where(draft_player_id: draft_player.id).where(draft_ranking_value_id: draft_ranking_value.id).first)
        ranking.update_column(:value,rankvalue)
      else
        self.create(:draft_ranking_value => draft_ranking_value, :draft_player => draft_player, :value => rankvalue)
      end
    end
  end
end
