class AddRankingValuePosition < ActiveRecord::Migration[5.2]
  def change
    add_column(:draft_ranking_values, :position, :string, limit: 10, null: true, default: 'default')
  end
end
