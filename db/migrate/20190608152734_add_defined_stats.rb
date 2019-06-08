class AddDefinedStats < ActiveRecord::Migration[5.2]
  def up

    create_table "defined_stats", force: :cascade do |t|
      t.string  "name", limit: 255
      t.integer "player_type", null: false, default: 1
      t.integer "category_code", null: false, default: 0
      t.integer "sort_direction", null: false, default: 1
      t.integer "stat_code", null: false, default: 1
      t.integer "default_display_order", null: false, default: 999
      t.text    "definition"
      t.index ["name","player_type"], name: "defined_stat_ndx", unique: true
    end

    DefinedStat.reset_column_information
    ignore_columns =[
      'id',
      'boxscore_id',
      'roster_id',
      'season',
      'team_id',
      'opposing_team_id',
      'location',
      'lineup',
      'name',
      'flag',
      'position',
      'first_name',
      'last_name',
      'created_at',
      'updated_at',
      'player_id',
      'bats',
      'throws'
    ]

    core_batting_columns = [
      'avg',
      'obp',
      'spc',
      'ab',
      'h',
      'h2b',
      'h3b',
      'hr',
      'r',
      'rbi',
      'hbp',
      'bb',
      'k',
      'sb',
      'gs',
      'pa',
      'ops',
      'rc',
      'rc27',
      'iso',
      'tavg',
      'sec',
      'ebh',
      'tb'
    ]

    core_pitching_columns = [
      'era',
      'w',
      'l',
      's',
      'g',
      'gs',
      'cg',
      'ip',
      'h',
      'r',
      'er',
      'bb',
      'k',
      'hr',
      'h_per_9',
      'bb_per_9',
      'r_per_9',
      'k_per_9',
      'hr_per_9',
      'k_per_bb',
      'whip',
      'ops',
      'rc',
      'rc27',
      'rcera',
      'cera'
    ]
    
  # directions
  pitching_descending_columns = [
    "age",
    "l",
    "era",
    "bb_per_9",
    "hr_per_9",
    "whip",
    "avg",
    "obp",
    "spc",
    "ops",
    "babip",
    "rc",
    "rc27",
    "rcera",
    "cera",
    "fip",
    "xfip",
    "l_avg",
    "l_obp",
    "l_spc",
    "l_ops",
    "l_pa",
    "r_avg",
    "r_obp",
    "r_spc",
    "r_ops",
    "r_pa"
  ]
  
    batting_descending_columns = [
      "age",
      "k"
    ]

    # batting stats
    batting_names = (BattingStat.column_names + RealBattingStat.column_names + GameBattingStat.column_names).uniq
    batting_names.reject!{|column| ignore_columns.include?(column)}
    batting_names.each do |name|
      DefinedStat.create(name: name, 
                         player_type: DefinedStat::BATTING,
                         category_code: ((core_batting_columns.include?(name)) ? DefinedStat::CORE : DefinedStat::SECONDARY),
                         sort_direction: ((batting_descending_columns.include?(name)) ? DefinedStat::DESCENDING : DefinedStat::ASCENDING),
                         default_display_order: (core_batting_columns.index(name) || 999))
    end


    # pitching stats
    pitching_names = (PitchingStat.column_names + RealPitchingStat.column_names + GamePitchingStat.column_names).uniq
    pitching_names.reject!{|column| ignore_columns.include?(column)}
    pitching_names.each do |name|
      DefinedStat.create(name: name, 
                         player_type: DefinedStat::PITCHING,
                         category_code: ((core_pitching_columns.include?(name)) ? DefinedStat::CORE : DefinedStat::SECONDARY),
                         sort_direction: ((pitching_descending_columns.include?(name)) ? DefinedStat::DESCENDING : DefinedStat::ASCENDING),
                         default_display_order: (core_pitching_columns.index(name) || 999))
    end

  end

  def down
    remove_index "defined_stats", name: "defined_stat_ndx"
    drop_table("defined_stats")
  end
end
