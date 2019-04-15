# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Boxscore < ApplicationRecord
  require 'pp'
  serialize :content
  serialize :stats
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'
  belongs_to :winning_team, :class_name => 'Team'
  has_many :games
  has_many :innings
  after_create :create_games, :create_innings

  # 2011040500000
  # 4/5/2011, Cle11-Bal11, Oriole Park at Camden Yards
  #
  #                        1  2  3  4  5  6  7  8  9     R  H  E   LOB DP
  # 2011 Indians           1  0  0  0  0  0  0  0  0     1  4  0     4  0
  # 2011 Orioles           0  1  2  0  0  0  0  0  x     3  6  0     4  2
  #
  # Indians              AB  R  H BI   AVG    Orioles              AB  R  H BI   AVG
  # Escobar,Y         ss  3  0  0  0  .000    Stubbs            cf  4  0  0  0  .000
  # Martin,R          c   4  0  0  0  .000    Young,Mi          3b  4  1  2  1  .500
  # Rodriguez,Al      3b  3  1  1  1  .333    Gonzalez,Ad       1b  3  0  0  0  .000
  # Ortiz,D           1b  4  0  1  0  .250    Braun             lf  4  1  1  0  .250
  # Morrison          lf  3  0  0  0  .000    Morgan            rf  3  0  1  1  .333
  # Weeks,J           2b  3  0  1  0  .333    Saltalamacchia    c   3  0  0  0  .000
  # Young,CB          cf  3  0  0  0  .000    Barmes            ss  3  0  1  1  .333
  # Venable           rf  3  0  1  0  .333    Rodriguez,S       2b  3  0  0  0  .000
  # Zimmermann        p   1  0  0  0  .000    Hellickson        p   3  1  1  0  .333
  #  Smoak            ph  1  0  0  0  .000     Robertson        p   0  0  0  0  .000
  #  Rodriguez,An     p   0  0  0  0  .000                         30  3  6  3
  #                      28  1  4  1
  #
  # Indians                          INN  H  R ER BB  K PCH STR   ERA
  # Zimmermann       L 0-1           7.0  5  3  3  1  4  94  61  3.86
  # Rodriguez,An                     1.0  1  0  0  0  1  17  10  0.00
  #                                  8.0  6  3  3  1  5 111  71
  #
  # Orioles                          INN  H  R ER BB  K PCH STR   ERA
  # Hellickson       W 1-0           8.0  4  1  1  2  4  99  67  1.13
  # Robertson        S 1             1.0  0  0  0  1  0  11   4  0.00
  #                                  9.0  4  1  1  3  4 110  71
  #
  # Cle: Smoak batted for Zimmermann in the 8th
  #
  # 2B-Young,Mi(1), Morgan(1), Barmes(1), Hellickson(1). HR-Rodriguez,Al(1).
  # RBI-Rodriguez,Al(1), Young,Mi(1), Morgan(1), Barmes(1). SB-Braun(1).
  # K-Martin,R, Weeks,J, Venable, Zimmermann, Stubbs, Gonzalez,Ad 2, Braun,
  # Morgan. BB-Escobar,Y, Rodriguez,Al, Morrison, Gonzalez,Ad. SH-Zimmermann.
  # GWRBI: Young,Mi
  # Justin Smoak was injured for this game and 7 more days
  # Temperature: 62, Sky: clear, Wind: in from center at 4 MPH.


  def self.download_boxscore_list(web_reports_url,game_results_page)
    results_list = []
    game_results_url = "#{web_reports_url}/#{game_results_page}"
    response = RestClient.get(game_results_url)
    if(!response.code == 200)
      return nil
    end
    htmldata = response.to_str
    doc = Nokogiri::HTML(htmldata)
    doc.search("a").each do |anchor|
      if(anchor['href'] and md = anchor['href'].match(%r{(?<boxscore>\d+)\.htm}))
        results_list << md[:boxscore]
      end
    end

    results_list
  end

  def self.get_all(season = Game.current_season)
    #build url from
    web_reports_url = "#{Settings.web_reports_base_url}/#{season}"
    self.get_all_from_url(web_reports_url,Settings.game_results_page,season) 
  end

  def self.get_all_from_url(web_reports_url,game_results_page,season)
    # boxscore_name = self.results_list.first
    processed = 0
    self.download_boxscore_list(web_reports_url,game_results_page).each do |boxscore_name|
      boxscore = Boxscore.get_and_create(web_reports_url,boxscore_name,season)
      processed +=1
    end
    processed
  end

  def self.get_and_create(web_reports_url,boxscore_name,season)
    if(!boxscore = Boxscore.where(season: season).where(name: boxscore_name).first)
      boxscore = Boxscore.new(:name => boxscore_name)
      boxscore_url = "#{web_reports_url}/#{boxscore_name}.htm"
      response = RestClient.get(boxscore_url)
      if(!response.code == 200)
        return nil
      end
      htmldata = response.to_str
      boxscore.content = content_array(htmldata)
      boxscore.process_content(season)
      boxscore.save!
    else
      # todo update?
    end
    boxscore
  end

  def self.content_array(htmldata)
    array_content = []
    doc = Nokogiri::HTML(htmldata)
    doc.search("pre").each do |pre_texts|
      pre_texts.content.each_line do |line|
        array_content << line.chomp
      end
    end

    # pop the top
    if(array_content.first.blank?)
      array_content.shift
    end

    array_content
  end

  def process_content(season)
    array_content = self.content.dup
    # first line
    process_date_teams_ballpark(array_content.shift,season)
    linescore_block = []
    while((array_content.first =~ %r{AB  R  H BI}).nil?)
      line = array_content.shift
      linescore_block << line unless line.blank?
    end
    linescore_block
    process_innings_totals(linescore_block)
  end

  def process_date_teams_ballpark(dataline,season)
    (linedate,teams,ballpark) = dataline.split(', ')
    self.date = Date.strptime(linedate, '%m/%d/%Y')
    self.season = season

    if(matcher = teams.match(%r{(?<away>\w+)\d\d-(?<home>\w+)\d\d}))
      home_abbrev = Team.abbreviation_transmogrifier(matcher[:home])
      away_abbrev = Team.abbreviation_transmogrifier(matcher[:away])
      self.home_team_id =  Team.where(abbrev: home_abbrev).first.id
      self.away_team_id =  Team.where(abbrev: away_abbrev).first.id
    end

    self.ballpark = ballpark
  end

  def process_innings_totals(linescore_data)
    self.stats = {}
    self.stats[self.home_team_id] = {}
    self.stats[self.away_team_id] = {}
    away_data =  linescore_data[1].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}
    home_data =  linescore_data[2].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}
    # remove years
    away_data.shift
    home_data.shift

    if(linescore_data[0] =~ %r{R\s+H\s+E})
      self.total_innings = linescore_data[0].split(/\s+/).map{|item| item.to_i}.max
    else
      self.total_innings = linescore_data[3].split(/\s+/).map{|item| item.to_i}.max
      tmp_away_data = linescore_data[4].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}
      tmp_home_data = linescore_data[5].gsub('x','-1').split(%r{\s+}).select{|item| (item.to_i.to_s == item || item.to_f.to_s == item)}

      # remove years
      tmp_away_data.shift
      tmp_home_data.shift

      # concat
      away_data += tmp_away_data
      home_data += tmp_home_data
    end

    self.stats[self.away_team_id][:innings] = away_data.slice!(0,self.total_innings).select{|value| value != '-1'}.map{|runs| runs.to_i}
    self.stats[self.home_team_id][:innings] = home_data.slice!(0,self.total_innings).select{|value| value != '-1'}.map{|runs| runs.to_i}
    (self.stats[self.away_team_id][:runs],
     self.stats[self.away_team_id][:hits],
     self.stats[self.away_team_id][:errors],
     self.stats[self.away_team_id][:lob],
     self.stats[self.away_team_id][:dp]) = away_data.map{|stat| stat.to_i}

     (self.stats[self.home_team_id][:runs],
      self.stats[self.home_team_id][:hits],
      self.stats[self.home_team_id][:errors],
      self.stats[self.home_team_id][:lob],
      self.stats[self.home_team_id][:dp]) = home_data.map{|stat| stat.to_i}

     self.home_runs = self.stats[self.home_team_id][:runs]
     self.away_runs = self.stats[self.away_team_id][:runs]
     if(home_runs > away_runs)
       self.winning_team_id = self.home_team_id
     else
       self.winning_team_id = self.away_team_id
     end

  end


  def home_innings
    self.stats[self.home_team_id][:innings].unshift(self.home_team_id)
  end

  def away_innings
    self.stats[self.away_team_id][:innings].unshift(self.away_team_id)
  end

  def create_games
    # home team's game
    home_game = Game.new(:boxscore_id => self.id, :date => self.date, :season => self.season)
    home_game.team_id = self.home_team_id
    home_game.home = true
    home_game.opponent_id = self.away_team_id
    home_game.win = (self.winning_team_id == self.home_team_id)
    home_game.runs = self.home_runs
    home_game.opponent_runs = self.away_runs
    home_game.total_innings = self.total_innings
    home_game.save!

    # away team's game
    away_game = Game.new(:boxscore_id => self.id, :date => self.date, :season => self.season)
    away_game.team_id = self.away_team_id
    away_game.home = false
    away_game.opponent_id = self.home_team_id
    away_game.win = (self.winning_team_id == self.away_team_id)
    away_game.runs = self.away_runs
    away_game.opponent_runs = self.home_runs
    away_game.total_innings = self.total_innings
    away_game.save!
  end

  def create_innings
    home_innings = self.home_innings
    away_innings = self.away_innings
    for i in (1..self.total_innings)
      if(home_innings[i])
        create_data = {:team_id => self.home_team_id, :inning => i, :runs => home_innings[i], :season => self.season}
        if(away_innings[i])
          create_data[:opponent_runs] = away_innings[i]
        end
        self.innings.create(create_data)
      end

      if(away_innings[i])
        create_data = {:team_id => self.away_team_id, :inning => i, :runs => away_innings[i], :season => self.season}
        if(home_innings[i])
          create_data[:opponent_runs] = home_innings[i]
        end
        self.innings.create(create_data)
      end
    end
  end



end
