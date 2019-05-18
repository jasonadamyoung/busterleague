class AddTransactionLog < ActiveRecord::Migration[5.2]
  def change

    create_table "transaction_logs", force: :cascade do |t|
      t.string    "hashid", limit: 255, null: false
      t.date      "date", null: false
      t.integer   "season", null: false
      t.integer   "roster_id"
      t.string    "name", limit: 255, default: "", null: false
      t.integer   "action", null: false
      t.string    "action_text", limit: 255, default: "", null: false
      t.integer   "team_id", null: false
      t.string    "team_string", limit: 4, default: "", null: false
      t.integer   "other_team_id"
      t.string    "other_team_string", limit: 4
      t.date      "effective_date"
      t.string    "when_string", limit: 255
    end

    add_index "transaction_logs", ["hashid","season"], name: "record_ndx", unique: true
    add_index "transaction_logs", ["name","team_id"], name: "name_team_ndx"

    remove_column(:rosters, :created_at, :datetime)
    remove_column(:rosters, :updated_at, :datetime)
    add_column(:rosters, :status, :string)
    add_column(:rosters, :status_code, :integer)
    add_column(:rosters, :trade_status, :integer)
    add_column(:rosters, :trade_team_id, :integer)

  end
end
