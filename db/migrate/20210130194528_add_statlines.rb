class AddStatlines < ActiveRecord::Migration[5.2]
  def change
    create_table "draft_batting_statlines", id: :integer, force: :cascade do |t|
      t.string "firstname", default: "", null: false
      t.string "lastname", default: "", null: false
      t.string "dmbteam", default: "", null: false
      t.string "position", limit: 3, default: "", null: false
      t.integer "age", default: 0, null: false
      t.float "avg", null: false
      t.float "obp", null: false
      t.float "spc", null: false
      t.float "ops", default: 0.0, null: false
      t.integer "opsplus", default: 0
      t.integer "gs", default: 0
      t.integer "pa", default: 0
      t.integer "ab", null: false
      t.integer "homeruns", default: 0, null: false
      t.integer "runs", default: 0, null: false
      t.integer "rbi", default: 0, null: false
      t.integer "walks", default: 0, null: false
      t.integer "strikeouts", null: false
      t.integer "sb", null: false
      t.float "rc", default: 0.0
      t.float "rc27", default: 0.0, null: false
      t.float "babip", default: 0.0
      t.float "wrcplus", default: 0.0
      t.float "woba", default: 0.0
      t.float "warfg", default: 0.0
      t.float "warbr", default: 0.0
      t.float "iso", default: 0.0
      t.integer "ebh", default: 0
      t.integer "tb", default: 0
      t.float "lavg", null: false
      t.float "lobp", null: false
      t.float "lspc", null: false
      t.float "lops", null: false
      t.integer "lpa", default: 0, null: false
      t.float "ravg", null: false
      t.float "robp", null: false
      t.float "rspc", null: false
      t.float "rops", null: false
      t.integer "rpa", default: 0, null: false
      t.string "injury", limit: 10, default: "", null: false
      t.string "stl", limit: 10, default: "", null: false
      t.string "run", limit: 10, default: "", null: false
      t.string "c", limit: 10, default: "", null: false
      t.string "first", limit: 10, default: "", null: false
      t.string "second", limit: 10, default: "", null: false
      t.string "third", limit: 10, default: "", null: false
      t.string "ss", limit: 10, default: "", null: false
      t.string "cf", limit: 10, default: "", null: false
      t.string "lf", limit: 10, default: "", null: false
      t.string "rf", limit: 10, default: "", null: false
      t.string "cthr", limit: 10, default: "", null: false
      t.string "othr", limit: 10, default: "", null: false
      t.string "bats", limit: 128, default: "'n/a'"
    end

    create_table "draft_pitching_statlines", id: :integer, force: :cascade do |t|
      t.string "firstname", default: "", null: false
      t.string "lastname", default: "", null: false
      t.string "dmbteam", default: "", null: false
      t.string "position", limit: 3, default: "", null: false
      t.string "throws", limit: 10, default: "U"
      t.integer "age", default: 0, null: false
      t.integer "games", default: 0
      t.integer "gs", default: 0
      t.float "innings", default: 0.0
      t.integer "wins", default: 0
      t.integer "losses", default: 0
      t.integer "saves", default: 0
      t.integer "strikeouts", default: 0
      t.float "era", default: 0.0
      t.float "eraplus", default: 0.0
      t.float "knine", default: 0.0
      t.float "walksnine", default: 0.0
      t.float "hnine", default: 0.0
      t.float "hrnine", default: 0.0
      t.float "kperwalk", default: 0.0
      t.float "whip", default: 0.0
      t.float "avg", default: 0.0
      t.float "obp", default: 0.0
      t.float "spc", default: 0.0
      t.float "ops", default: 0.0
      t.float "babip", default: 0.0
      t.float "rc", default: 0.0
      t.float "rc27", default: 0.0
      t.float "rcera", default: 0.0
      t.float "cera", default: 0.0
      t.float "fip", default: 0.0
      t.float "xfip", default: 0.0
      t.float "warfg", default: 0.0
      t.float "warbr", default: 0.0
      t.float "lavg", default: 0.0
      t.float "lobp", default: 0.0
      t.float "lspc", default: 0.0
      t.float "lops", default: 0.0
      t.integer "lpa", default: 0
      t.float "ravg", default: 0.0
      t.float "robp", default: 0.0
      t.float "rspc", default: 0.0
      t.float "rops", default: 0.0
      t.integer "rpa", default: 0
      t.string "sdur", limit: 10, default: "u"
      t.string "rdur", limit: 10, default: "u"
      t.string "injury", limit: 10, default: "u"
    end

  end
end
