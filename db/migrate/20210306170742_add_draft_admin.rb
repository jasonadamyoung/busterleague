class AddDraftAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column(:owners, :is_draft_admin, :boolean, null: false, default: false)
  end
end
