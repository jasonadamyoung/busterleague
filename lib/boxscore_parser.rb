# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class BoxscoreParser
  include ParserUtils

  attr_accessor :content
  attr_accessor :date_teams_ballpark_data
  attr_accessor :innings_totals_data
  attr_accessor :away_at_bat_data
  attr_accessor :home_at_bat_data
  attr_accessor :away_pitching_data
  attr_accessor :home_pitching_data
  attr_accessor :substitution_data
  attr_accessor :game_stat_data
  attr_accessor :injury_data
  attr_accessor :removed_data
  attr_accessor :ejected_data
  attr_accessor :gwrbi_data
  attr_accessor :weather_data

  attr_accessor :innings_totals
  attr_accessor :date_teams_ballpark

  attr_accessor :game_stat_data_hash
  attr_accessor :home_ab_data_hash
  attr_accessor :away_ab_data_hash
  attr_accessor :home_pitching_data_hash
  attr_accessor :away_pitching_data_hash

  attr_accessor :batting_stats
  attr_accessor :pitching_stats


  
  def initialize(content)
    self.content = content
    self.date_teams_ballpark_data = []
    self.innings_totals_data = []
    self.away_at_bat_data = []
    self.home_at_bat_data = []
    self.away_pitching_data = []
    self.home_pitching_data = []
    self.substitution_data = []
    self.game_stat_data = []
    self.injury_data = []
    self.removed_data = []
    self.ejected_data = []
    self.gwrbi_data = []
    self.weather_data = []
    self.process_parts
    self.process_data
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
      line = more_mass_name_nonsense(array_content.shift)    
      at_bat_block << line unless line.strip.empty?
    end
    at_bat_block.each do |line|
      (away_string,home_string) = [line[0..37],line[42..-1]]
      # ignore summary line
      if(!away_string.nil? and !away_string.strip.empty?)
        self.away_at_bat_data << away_string
      end
      if(!home_string.nil? and !home_string.strip.empty?)
        self.home_at_bat_data << home_string.rstrip
      end
    end
    # pop off summary lines
    self.away_at_bat_data.pop
    self.home_at_bat_data.pop
    
    ## pitching_data
    # away
    while(!array_content.first.strip.empty?)
      line = more_mass_name_nonsense(array_content.shift)    
      self.away_pitching_data << line
    end
    # pop off the summary line
    self.away_pitching_data.pop

    while(array_content.first.strip.empty?)
      array_content.shift
    end

    # home
    while(!array_content.first.strip.empty?)
      line = more_mass_name_nonsense(array_content.shift)    
      self.home_pitching_data << line
    end
    # pop off the summary line
    self.home_pitching_data.pop

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

    game_stat_data_block = []
    # game_stat_data
    while(!(array_content.first =~ %r{^[a-zA-Z\s]+:}) and !(array_content.first =~ %r{injured}) and !(array_content.first =~ %r{removed}) and !(array_content.first =~ %r{ejected}) and !array_content.first.nil?)
      line = more_mass_name_nonsense(array_content.shift)    
      game_stat_data_block << line unless line.strip.empty?
    end

    game_stat_data_block.join(' ').split('.').each do |game_stat_data_item|
      self.game_stat_data << game_stat_data_item.strip unless game_stat_data_item.strip.empty?
    end

    while(!array_content.first.nil? and !(array_content.first == self.date_teams_ballpark_data))
      # injury data
      while(array_content.first =~ %r{injured})
        line = array_content.shift      
        self.injury_data << line unless line.strip.empty?
      end

      # removed data
      while(array_content.first =~ %r{removed})
        line = array_content.shift      
        self.removed_data << line unless line.strip.empty?
      end

      # ejected data
      while(array_content.first =~ %r{ejected})
        line = array_content.shift      
        self.ejected_data << line unless line.strip.empty?
      end    

      # GWRBI
      if(array_content.first =~ %r{^GWRBI:})
        self.gwrbi_data << array_content.shift
      end

      # Weather
      if(array_content.first =~ %r{^Temperature:} or array_content.first =~ %r{^Rain})
        while(!array_content.first.nil? and !array_content.first.empty? and !(array_content.first == self.date_teams_ballpark_data))
          self.weather_data << array_content.shift
        end
      end

    end

    true

  end

  def process_data
    self.process_date_teams_ballpark
    self.process_innings_totals
    self.process_game_stat_data_hash
    self.process_ab_data_hash
    self.process_pitching_data_hash
    self.process_batting_stats
    self.process_pitching_stats
  end


  def process_date_teams_ballpark
    returndata = {}
    (linedate,teams,ballpark) = self.date_teams_ballpark_data.split(', ')
    returndata['date'] = Date.strptime(linedate, '%m/%d/%Y')
    returndata['ballpark'] = ballpark

    if(matcher = teams.match(%r{(?<away>\w+)\d\d-(?<home>\w+)\d\d}))
      returndata['home_team'] = matcher[:home]
      returndata['away_team'] = matcher[:away]
    end

    self.date_teams_ballpark = returndata
  end
  
  def process_innings_totals
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
     returndata['total_innings'] = total_innings
     returndata['home_runs'] = home_team_stats["runs"]
     returndata['away_runs'] = away_team_stats["runs"]
     returndata['home_team_stats'] = home_team_stats
     returndata['away_team_stats'] = away_team_stats

     self.innings_totals = returndata
  end

  def process_game_stat_data_hash
    game_stat_data_hash = {'batting' => {}, 'pitching' => {}, 'fielding' => {}}
    self.game_stat_data.each do |batstat|
      (stat,names) = batstat.split('-')
      stat = label_translation(stat).downcase
      names.split(', ').each do |namedata|
        # remove any totals
        namedata.gsub!(%r{\(\d+\)},'')
        if(namedata =~ %r{(\D+)(\d+)})
          statcount = $2.to_i
          name = $1.strip
        else 
          statcount = 1
          name = namedata.strip
        end

        # all because of Jones(R)
        name.gsub!(%r{[\(\)]},'')

        # stat category
        if(['wp','hb','balk'].include?(stat))
          category = 'pitching'
        elsif(['pb','e','ci'].include?(stat))
          category = 'fielding'
        else
          category = 'batting'
        end

        if(game_stat_data_hash[category][name])
          game_stat_data_hash[category][name] = game_stat_data_hash[category][name].merge({stat.downcase => statcount})
        else
          game_stat_data_hash[category][name] = {stat => statcount}
        end
      end
    end
    self.game_stat_data_hash = game_stat_data_hash
  end

  def game_stat_data_stats
    game_stat_data_stats = []
    self.game_stat_data_hash.each do |name,category_data|
      category_data.each do |category, game_stat_data|
        game_stat_data_stats += game_stat_data.keys
      end
    end
    game_stat_data_stats.uniq
  end


  def process_ab_data_hash
    self.home_ab_data_hash = self.ab_data_hash('home')
    self.away_ab_data_hash = self.ab_data_hash('away')
  end

  def ab_data_hash(home_or_away)
    ab_data_hash = {}
    ab_data = (home_or_away == 'home') ? self.home_at_bat_data.dup :  self.away_at_bat_data.dup
    ab_data.shift # ignore header row
    lineup = 0
    ab_data.each do |dataline| 
      (name,position_and_stats) = [dataline[0..17].strip,dataline[18..-1].split(%r{\s+})]
      name = name_transforms(name)
      if(dataline =~ %r{^\s+})
        is_substitution = true
      else
        lineup += 1
        is_substitution = false
      end
      data_hash = {'position' => position_and_stats[0].downcase,
                      'ab' => position_and_stats[1].to_i,
                      'r' => position_and_stats[2].to_i,
                      'h' => position_and_stats[3].to_i,
                      'rbi' => position_and_stats[4].to_i,
                      'gs' => is_substitution ? 0 : 1,
                      'lineup' => lineup
                    }
      ab_data_hash[name] = data_hash
    end
    ab_data_hash
  end

  def process_batting_stats
    batting_stats = {}
    batting_stats[:home_batting_stats] = self.home_ab_data_hash
    batting_stats[:away_batting_stats] = self.away_ab_data_hash
    batting_stats[:unknown_batting_stats] = {}

    self.game_stat_data_hash['batting'].each do |name,game_stat_data|
      if(batting_stats[:home_batting_stats][name])
        batting_stats[:home_batting_stats][name].merge!(game_stat_data)
      elsif(batting_stats[:away_batting_stats][name])
        batting_stats[:away_batting_stats][name].merge!(game_stat_data)
      else
        batting_stats[:unknown_batting_stats][name] = game_stat_data
      end
    end
    self.batting_stats = batting_stats
  end

  def process_pitching_data_hash
    self.home_pitching_data_hash = self.pitching_data_hash('home')
    self.away_pitching_data_hash = self.pitching_data_hash('away')
  end

  def pitching_data_hash(home_or_away)
    pitching_data_hash = {}
    pitching_data = (home_or_away == 'home') ? self.home_pitching_data.dup :  self.away_pitching_data.dup
    pitching_data.shift # ignore header row`
    pitching_data.each do |dataline|
      data_hash = {}
      (name_and_action,stats) = [dataline[0..30].strip,dataline[31..-1].strip.split(%r{\s+})]
      if(position = (name_and_action =~ %r{([A-Z]{1,2})\s+([\d-]+)}))
        action = $1.downcase
        data_hash[action] = 1
        name = name_and_action[0..position-1].strip
      else
        name = name_and_action
      end

      # all because of Jones(R)
      name.gsub!(%r{[\(\)]},'')

      (int,frac) = stats[0].split('.')
      data_hash['ip'] = int.to_f + (frac.to_f / 3)
      data_hash['h'] = stats[1].to_i
      data_hash['r'] = stats[2].to_i
      data_hash['er'] = stats[3].to_i
      data_hash['bb'] = stats[4].to_i
      data_hash['k'] = stats[5].to_i
      data_hash['pch'] = stats[6].to_i
      data_hash['str'] = stats[7].to_i
      pitching_data_hash[name] = data_hash
    end  
    pitching_data_hash
  end

  def process_pitching_stats
    pitching_stats = {}
    pitching_stats[:home_pitching_stats] = self.home_pitching_data_hash
    pitching_stats[:away_pitching_stats] = self.away_pitching_data_hash
    pitching_stats[:unknown_pitching_stats] = {}

    self.game_stat_data_hash['pitching'].each do |name,game_stat_data|
      if(pitching_stats[:home_pitching_stats][name])
        pitching_stats[:home_pitching_stats][name].merge!(game_stat_data)
      elsif(pitching_stats[:away_pitching_stats][name])
        pitching_stats[:away_pitching_stats][name].merge!(game_stat_data)
      else
        pitching_stats[:unknown_pitching_stats][name] = game_stat_data
      end
    end
  
    self.pitching_stats = pitching_stats
  end

end
