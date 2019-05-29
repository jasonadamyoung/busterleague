# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file


class GameResultsParser
  include ParserUtils

  attr_accessor :htmlcontent
  attr_accessor :htmldoc
  attr_accessor :game_results_table
  attr_accessor :game_results_data


  def initialize(htmlcontent)
    self.htmldoc = Nokogiri::HTML(htmlcontent)
    self.game_results_table = self.htmldoc.search('table').first
    self.game_results_data = {}
    self.process_table
  end

  def process_table(options = {})
    returnhash = {}
    rows = game_results_table.search('tr')
    # Date	#	Inn	Away	R	Home	R	Win	Loss	Save	GWRBI
    rows[2..-1].each do |row|
      cells = row.search('td')
      gr_details = {}
      gr_details['date'] = Date.strptime(cell_text(cells[0]), '%m/%d/%Y')
      anchors = cells[0].search("a")
      if(!anchors.empty?)
        if(anchors[0]['href'] and md = anchors[0]['href'].match(%r{(?<boxscore>\d+)\.htm}))
          gr_details['boxscore_name'] = md[:boxscore]
        end
      end
      ti = cell_text(cells[2])
      if(ti.nil? or ti.empty?)
        gr_details['total_innings'] = 9
      else
        gr_details['total_innings'] = ti.to_i
      end 
      gr_details['away_team_string'] = cell_text(cells[3])
      gr_details['away_runs'] = cell_text(cells[4]).to_i
      gr_details['home_team_string'] = cell_text(cells[5])
      gr_details['home_runs'] = cell_text(cells[6]).to_i
      gr_details['winning_pitcher_name'] = cell_text(cells[7])
      gr_details['losing_pitcher_name'] = cell_text(cells[8])
      gr_details['save_pitcher_name'] = cell_text(cells[9])
      gr_details['gwrbi_name'] = cell_text(cells[10])
      hashkey = keyme(gr_details['date'].to_s,gr_details['away_team_string'],gr_details['home_team_string'])
      returnhash[hashkey] = gr_details
    end
    self.game_results_data = returnhash
  end

end