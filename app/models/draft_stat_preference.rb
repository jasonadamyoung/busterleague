# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftStatPreference < ApplicationRecord
  belongs_to :owner
  serialize :column_list

  # player types
  PITCHER = 1
  BATTER = 2

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


  def column_list_tokeninput
    self.column_list.blank? ? {} : self.column_list.collect{|attribute| {id: attribute, name: attribute}}
  end

  def column_list=(column_list)
    if(column_list.is_a?(Array))
      write_attribute(:column_list, column_list)
    elsif(column_list.is_a?(String))
      write_attribute(:column_list, column_list.split(','))
    else
      write_attribute(:column_list, nil)
    end
  end

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

  def self.available_display_stats(playertype)
    reject_columns =  ['id','firstname','lastname','dmbteam']
    case playertype
    when PITCHER
      DraftPitchingStatline.column_names.reject{|column| reject_columns.include?(column)}
    when BATTER
      DraftBattingStatline.column_names.reject{|column| reject_columns.include?(column)}
    end
  end

  def self.core_display_stats(playertype)
    case playertype
    when PITCHER
      ['position','age','throws'] + DraftStatDistribution.core(playertype)
    when BATTER
      ['age','bats'] + DraftStatDistribution.core(playertype) + DraftBattingStatline::RATINGFIELDS.values
    end
  end

  def self.default
    where(:owner_id => Owner.computer.id).first
  end

  def self.fix_stat_preferences
    pitching_columns = DraftPitchingStatline.columns.map(&:name)
    batting_columns  = DraftBattingStatline.columns.map(&:name)

    StatPreference.all.each do |sp|
      if(sp.playertype == PITCHER)
        dump_values = sp.column_list - pitching_columns
      else
        dump_values = sp.column_list - batting_columns
      end

      new_column_list = sp.column_list.reject{|stat| dump_values.include?(stat)}
      sp.update_attribute(:column_list, new_column_list)
    end
  end

end
