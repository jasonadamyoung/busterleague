# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftRankingValue < ApplicationRecord
  belongs_to :owner
  has_many :draft_rankings
  serialize :formula

  # player types
  PITCHER = 1
  BATTER = 2

  IMPORTANCES = { "High" => 1, "Medium" => 2, "Low" => 3 }
  IMPORTANCE_FACTORS = {1 => 1.to_f, 2 => Rational(2,3), 3 => Rational(1,3)}
  DEFAULT_IMPORTANCE = 1

  # normalizations
  NORMALIZED_SCALE = 1
  NORMALIZED_AVERAGE = 2
  NORMALIZED_NOT = 3

  scope :pitching, -> { where(playertype: PITCHER) }
  scope :batting, -> { where(playertype: BATTER) }


  def self.playertype_to_s(playertype)
    case playertype
    when PITCHER
      'Pitcher'
    when BATTER
      'Batter'
    else
      'Unknown'
    end
  end

  def playertype_to_s
    self.class.playertype_to_s(self.playertype)
  end

  def create_or_update_rankings
    Ranking.create_or_update_from_ranking_value(self)
    return true
  end

  def rankings_distribution(options = {})
    rankings_distribution_hash = {}
    normalization = options[:normalization] || NORMALIZED_SCALE
    player_list = options[:player_list] || ((self.playertype == PITCHER) ? Pitcher.all : Batter.all )

    self.formula.each do |factor|
      column = factor[:column]
      importance = self.class.importance_factor(factor[:importance],options[:importance_factors])
      stat = Stat.find_or_create(self.playertype,column)

      # go through and build up the rankings by player totaled for all the factors
      player_list.each do |player|
        scaled_stat = stat.scaled_distribution[:players][player.id] ? stat.scaled_distribution[:players][player.id] : 0
        if(rankings_distribution_hash[player].nil?)
          rankings_distribution_hash[player] = (scaled_stat * importance)
        else
          rankings_distribution_hash[player] += (scaled_stat * importance)
        end
      end
    end

    # normalize the rankings
    if(normalization == NORMALIZED_SCALE)
      median = rankings_distribution_hash.values.median
      range = (rankings_distribution_hash.values.max - rankings_distribution_hash.values.min).to_f
      rankings_distribution_hash.each do |player,stat|
        rankings_distribution_hash[player] = ((stat - median)/range)
      end
    elsif(normalization == NORMALIZED_AVERAGE)
      total_importance = self.formula.map{|factor| DraftRankingValue.importance_factor(factor[:importance],options[:importance_factors])}.sum

      rankings_distribution_hash.each do |player,stat|
        rankings_distribution_hash[player] = (stat / total_importance)
      end
    else
      # nothing
    end

    # filter player list?
    if(options[:player_filter])
      rankings_distribution_hash.delete_if{|player,value| !(options[:player_filter].include?(player))}
    end

    rankings_distribution_hash
  end




  def self.default
    where(:owner_id => Owner.computer.id).first
  end

  def self.importance_factor(importance,custom_factors = nil)
    if(custom_factors)
      custom_factors[importance] ? custom_factors[importance] : 1
    else
      IMPORTANCE_FACTORS[importance] ? IMPORTANCE_FACTORS[importance] : 1
    end
  end

  def self.rebuild
    Stat.rebuild(all)
    DraftRankingValue.all.each do |rv|
      rv.create_or_update_rankings
    end
  end

  def self.fix_ranking_values
    pitching_columns = DraftPitchingStatline.columns.map(&:name)
    batting_columns  = DraftBattingStatline.columns.map(&:name)

    DraftRankingValue.all.each do |rv|
      column_names = rv.formula.map{|hash| hash[:column]}
      if(rv.playertype == PITCHER)
        dump_values = column_names - pitching_columns
      else
        dump_values = column_names - batting_columns
      end

      new_formula = rv.formula.reject{|component| dump_values.include?(component[:column])}
      rv.update_attribute(:formula, new_formula)
    end

    # rebuild all
    # self.rebuild
  end


end
