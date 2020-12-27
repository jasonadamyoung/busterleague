# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftRanking < ApplicationRecord
  belongs_to :player
  belongs_to :draft_ranking_value

  def self.create_or_update_from_ranking_value(ranking_value)
    rankings = ranking_value.rankings_distribution
    rankings.each do |player,rankvalue|
      if(ranking = self.where(player_id: player.id).where(ranking_value_id: ranking_value.id).first)
        ranking.update_column(:value,rankvalue)
      else
        self.create(:ranking_value => ranking_value, :player => player, :value => rankvalue)
      end
    end
  end
end
