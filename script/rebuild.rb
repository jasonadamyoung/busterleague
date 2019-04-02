#!/usr/bin/env ruby
require 'rubygems'
require 'thor'
require 'benchmark'

class Rebuilder < Thor
  include Thor::Actions

  # these are not the tasks that you seek
  no_tasks do
    # load rails based on environment

    def load_rails(environment)
      if !ENV["RAILS_ENV"] || ENV["RAILS_ENV"] == ""
        ENV["RAILS_ENV"] = environment
      end
      require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
    end


    def run_and_log(rebuilder,model,action)
      puts "Starting #{model}##{action}..." if options[:verbose]
      run_time = rebuilder.run_and_log(model,action)
      puts "\t Finished #{model}##{action} (#{run_time.round(2)}s)" if options[:verbose]
    end

    def rebuild_group(group)
      rebuilder = Rebuild.start(group)
      rebuilder.list_of_rebuilds.each do |(model,action)|
        run_and_log(rebuilder,model,action)
      end
      rebuilder.finish
    end


    def rebuild_single(model,method='rebuild')
      rebuilder = Rebuild.start(group)
      run_and_log(rebuilder,model,action)
      rebuilder.finish
    end
  end


  desc "all_the_things", "Import boxscores and rebuild stats"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  method_option :verbose,:default => true, :aliases => "-v", :desc => "Show progress"
  def all_the_things
    load_rails(options[:environment])
    Rails.cache.clear
    rebuild_group('all')
  end

  desc "model", "Rebuild a specific model"
  method_option :environment,:default => 'production', :aliases => "-e", :desc => "Rails environment"
  method_option :verbose,:default => true, :aliases => "-v", :desc => "Show progress"
  method_option :name, :aliases => "-n", :desc => "Model name", required: true
  method_option :method, :aliases => "-m", default: 'rebuild', :desc => "Model method"
  def model
    load_rails(options[:environment])
    rebuild_single(options[:name],options[:method])
  end

end

Rebuilder.start
