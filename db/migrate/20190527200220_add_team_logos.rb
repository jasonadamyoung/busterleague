class AddTeamLogos < ActiveRecord::Migration[5.2]
  def change
    add_column(:teams, :svglogo, :text)
    remove_column(:teams, :created_at, :datetime)
    remove_column(:teams, :updated_at, :datetime)
  end
end
