class AddRankingValuePosition < ActiveRecord::Migration[5.2]
  def change
    add_column(:draft_ranking_values, :position, :string, limit: 3, null: true, default: 'all')
  end
end
