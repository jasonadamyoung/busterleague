# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# Based on open source code written originally by Jason Adam Young
# as part of the "positronic" application at NC State University,
# funding by the National eXtension Initiative
# === LICENSE:
# see LICENSE file

class Rebuild < ApplicationRecord
  serialize :rebuild_results

  BOXSCORES_REBUILD = [{'Boxscore' => 'get_all'}]
  STATS_REBUILD = ['Game','Inning','Record']


  def run_and_log(model,action)
    object = Object.const_get(model)
    self.update_attributes(current_model: model, current_action: action, current_start: Time.now)
    results = ''
    benchmark = Benchmark.measure do
      results = object.send(action)
    end
    self.update_attributes(current_model: '', current_action: '', current_start: '')
    benchmark.real
  end

  def self.start(group)
    self.create(group: group, in_progress: true, started: Time.now)
  end

  def self.start_single(model,action)
    self.create(group: 'single', single_model: model, single_action: action, in_progress: true, started: Time.now)
  end

  def finish
    finished = Time.now
    self.update_attributes(in_progress: false, finished: finished, run_time: (finished - started))
  end

  def list_of_rebuilds
    case self.group
    when 'all'
      list = BOXSCORES_REBUILD + STATS_REBUILD
    when 'boxscores'
      list = BOXSCORES_REBUILD
    when 'stats'
      list = STATS_REBUILD
    when 'single'
      list = [{self.single_model => self.single_action}]
    end

    returnlist = []
    list.each do |item|
      if(item.is_a?(String))
        returnlist << [item,'rebuild']
      elsif(item.is_a?(Hash))
        item.each do |model,action|
          returnlist << [model,action]
        end
      end
    end
    returnlist
  end

  def run_all
    results = {}
    list_of_rebuilds.each do |(model,action)|
      results["#{model}.#{action}"] = run_and_log(model,action)
    end
    self.update_attribute(:rebuild_results, results)
    results
  end

  def run_all_and_finish
    self.run_all
    self.finish
  end

  def self.latest
    order('created_at DESC').first
  end

end
