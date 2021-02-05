# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftStatDistribution < ApplicationRecord
  include CleanupTools
  serialize :distribution
  serialize :scaled_distribution

  # player type
  PITCHER = 1
  BATTER  = 2

  scope :batting, ->{where(player_type: DraftStatDistribution::BATTER)}
  scope :pitching, ->{where(player_type: DraftStatDistribution::PITCHER)}

  def self.core(player_type)
    list = []
    if(player_type == BATTER)
      list += ['ab','ops','l_ops','r_ops','opsplus','war_fg','war_br']
    else
      list += ['w','s','era','whip','fip']
      list += ['xfip','war_fg','war_br','eraplus','hr_per_9','k_per_9','bb_per_9','l_ops','r_ops','ops']
     end
    list
  end

  def self.create_or_update_from_defined_stat(defined_stat)
    if(!(dsd = self.where(defined_stat_id: defined_stat.id).first))
      dsd = self.new(defined_stat_id: defined_stat.id, :player_type => defined_stat.player_type, :label => defined_stat.name)
    end

    direction = defined_stat.sort_direction

    # get the list of players
    player_list = (dsd.player_type == PITCHER) ? DraftPitcher.includes(:statline).not_injured : DraftBatter.includes(:statline).not_injured
    player_distribution = {}
    player_list.each do |player|
      if(player.statline.age != 0)
        player_distribution[player.id] = player.statline.send(dsd.label)
      end
    end

    values_distribution = player_distribution.values
    dsd.mean = values_distribution.mean
    dsd.median = values_distribution.median
    dsd.max = values_distribution.max
    dsd.min = values_distribution.min
    dsd.range = (dsd.max - dsd.min).to_f

    scaled_player_distribution = {}
    player_distribution.each do |player_id,value|
      scaled_player_distribution[player_id] = ((value-dsd.median)/dsd.range) * direction
    end

    scaled_values_distribution = scaled_player_distribution.values

    dsd.distribution = {:players => player_distribution, :values => values_distribution}
    dsd.scaled_distribution = {:players => scaled_player_distribution, :values => scaled_values_distribution}
    dsd.save
    dsd
  end

  def self.find_or_create(player_type,label)
    defined_stat = DefinedStat.where(player_type: player_type).where(name: label).first
    if(defined_stat)
      stat = self.create_or_update_from_defined_stat(defined_stat)
    end
    stat
  end

  def self.rebuild
    self.dump_data
    DefinedStat.pitching_statlines.each do |pitching_stat|
      self.create_or_update_from_defined_stat(pitching_stat)
    end
    DefinedStat.batting_statlines.each do |batting_stat|
      self.create_or_update_from_defined_stat(batting_stat)
    end
  end

  def values(statcolumn,playerfilter = nil)
    values_list = self.send(statcolumn)[:players].dup

    if(playerfilter)
      player_ids = playerfilter.map(&:id)
      values_list.delete_if{|player_id,value| !(player_ids.include?(player_id))}
    end

    values_list.values.sort
  end


end
