class AddEnabledFlagToPrefs < ActiveRecord::Migration[5.2]
  def change
    add_column(:draft_owner_position_prefs, :enabled, :boolean, null: false, default: true)
  end
end
