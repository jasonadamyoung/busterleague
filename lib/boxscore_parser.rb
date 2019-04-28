# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class BoxscoreParser

  attr_accessor :content
  attr_accessor :date_teams_ballpark_data
  attr_accessor :innings_totals_data
  attr_accessor :away_at_bat_data
  attr_accessor :home_at_bat_data
  attr_accessor :away_pitching_data
  attr_accessor :home_pitching_data
  attr_accessor :substitution_data
  attr_accessor :batting_data
  attr_accessor :injury_data
  attr_accessor :gwrbi_data
  attr_accessor :temperature_data
  
  def initialize(content)
    self.content = content
    self.date_teams_ballpark_data = []
    self.innings_totals_data = []
    self.away_at_bat_data = []
    self.home_at_bat_data = []
    self.away_pitching_data = []
    self.home_pitching_data = []
    self.substitution_data = []
    self.batting_data = []
    self.injury_data = []
    self.gwrbi_data = []
    self.temperature_data = []
    self.process_parts
    self    
  end

  def process_parts
    array_content = self.content.dup
    # date_teams_ballpark
    self.date_teams_ballpark_data = array_content.shift

    ## innings_totals
    linescore_block = []
    while((array_content.first =~ %r{AB\s+R\s+H\s+BI}).nil?)
      line = array_content.shift
      linescore_block << line unless line.strip.empty?
    end
    self.innings_totals_data = linescore_block

    ## at_bat data
    at_bat_block = []
    while((array_content.first =~ %r{INN\s+H\s+R\s+ER}).nil?)
      line = array_content.shift
      at_bat_block << line unless line.strip.empty?
    end
    at_bat_block.each do |line|
      (away_string,home_string) = [line[0..37],line[42..-1]]
      # ignore summary line
      if(! away_string.strip.empty? and away_string =~ %r{^\s?[a-zA-z,]+\s+})
        self.away_at_bat_data << away_string
      end
      if(!home_string.strip.empty? and home_string =~ %r{^\s?[a-zA-z,]+\s+})
        self.home_at_bat_data << home_string.rstrip
      end
    end

    ## pitching_data
    # away
    while(!array_content.first.strip.empty?)
      line = array_content.shift
      # ignore summary line
      if(line =~ %r{^[a-zA-z,]+\s+})
        self.away_pitching_data << line
      end
    end

    while(array_content.first.strip.empty?)
      array_content.shift
    end

    # home
    while(!array_content.first.strip.empty?)
      line = array_content.shift
      # ignore summary line
      if(line =~ %r{^[a-zA-z,]+\s+})
        self.home_pitching_data << line
      end
    end

    while(array_content.first.strip.empty?)
      array_content.shift
    end

    # substitution_data
    if(array_content.first =~ %r{^[a-zA-Z\s]+:})
      while(!array_content.first.strip.empty?)
        line = array_content.shift      
        self.substitution_data << line unless line.strip.empty?
      end
    end

    while(array_content.first.strip.empty?)
      array_content.shift
    end

    batting_data_block = []
    # batting_data
    while(!(array_content.first =~ %r{^[a-zA-Z\s]+:}) and !(array_content.first =~ %r{injured}))
      line = array_content.shift      
      batting_data_block << line unless line.strip.empty?
    end

    batting_data_block.join(' ').split('.').each do |batting_data_item|
      self.batting_data << batting_data_item.strip unless batting_data_item.strip.empty?
    end

    # injury data
    while(array_content.first =~ %r{injured})
      line = array_content.shift      
      self.injury_data << line unless line.strip.empty?
    end

    # GWRBI
    if(array_content.first =~ %r{^GWRBI:})
      self.gwrbi_data << array_content.shift
    end

    # Temperature
    if(array_content.first =~ %r{^Temperature:})
      self.temperature_data << array_content.shift
    end

    true

  end

  def date_teams_ballpark
    returndata = {}
    (linedate,teams,ballpark) = self.date_teams_ballpark_data.split(', ')
    returndata[:date] = Date.strptime(linedate, '%m/%d/%Y')
    returndata[:ballpark] = ballpark

    if(matcher = teams.match(%r{(?<away>\w+)\d\d-(?<home>\w+)\d\d}))
      returndata[:home_team] = matcher[:home]
      returndata[:away_team] = matcher[:away]
    end

    returndata
  end
  
  def innings_totals
    home_team_stats = {}
    away_team_stats = {}
    away_data =  self.innings_totals_data[1].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}
    home_data =  self.innings_totals_data[2].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}
    # remove years
    away_data.shift
    home_data.shift

    if(self.innings_totals_data[0] =~ %r{R\s+H\s+E})
      total_innings = self.innings_totals_data[0].split(/\s+/).map{|item| item.to_i}.max
    else
      total_innings = self.innings_totals_data[3].split(/\s+/).map{|item| item.to_i}.max
      tmp_away_data = self.innings_totals_data[4].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}
      tmp_home_data = self.innings_totals_data[5].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}

      # remove years
      tmp_away_data.shift
      tmp_home_data.shift

      # concat
      away_data += tmp_away_data
      home_data += tmp_home_data
    end

    away_team_stats["innings"] = away_data.slice!(0,total_innings).select{|value| value != '-1'}.map{|runs| runs.to_i}
    home_team_stats["innings"] = home_data.slice!(0,total_innings).select{|value| value != '-1'}.map{|runs| runs.to_i}
    (away_team_stats["runs"],
     away_team_stats["hits"],
     away_team_stats["errors"],
     away_team_stats["lob"],
     away_team_stats["dp"]) = away_data.map{|stat| stat.to_i}

     (home_team_stats["runs"],
      home_team_stats["hits"],
      home_team_stats["errors"],
      home_team_stats["lob"],
      home_team_stats["dp"]) = home_data.map{|stat| stat.to_i}

     returndata = {}
     returndata[:total_innings] = total_innings
     returndata[:home_runs] = home_team_stats["runs"]
     returndata[:away_runs] = away_team_stats["runs"]
     returndata[:home_team_stats] = home_team_stats
     returndata[:away_team_stats] = away_team_stats

     returndata
  end


end
