# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file


class RosterParser
  include ParserUtils

  attr_accessor :htmlcontent
  attr_accessor :htmldoc
  attr_accessor :tables
  attr_accessor :roster

  BATTING_TABLE = 0
  PITCHING_TABLE = 1
  FIELDING_TABLE = 2
  CONTRACT_TABLE = 3


  def initialize(htmlcontent)
    self.htmldoc = Nokogiri::HTML(htmlcontent)
    self.tables = self.htmldoc.search('table')
    self.process_tables 
  end

  def process_tables
    self.process_contract_table
  end

  def name_fixer(name)
    case name
    when 'Valeri delosSantos'
      'Valerio de los Santos'
    when 'Paul LoDuca'
      'Paul Lo Duca'
    else
      name
    end
  end


  def process_contract_table
    self.roster = {}
    contract_table = self.tables[CONTRACT_TABLE]
    rows = contract_table.search('tr')
    # attributes
    # S	Name	P	Bats	T	Age	%Act	%Dis	Salary	Year
    # ignore first three (header) and last (total) rows
    rows[3..-2].each do |row|
      cells = row.search('td')
      player_details = {}
      contract_data = {}
      status = cell_text(cells[0])
      player_details['status'] = (status == 'f') ? 'reserve' : 'active'
      player_details['name'] = name_fixer(cell_text(cells[1]))
      player_details['end_name'] = player_details['name'].split(' ').last
      player_details['position'] = cell_text(cells[2]).downcase
      player_details['bats'] = cell_text(cells[3]).downcase
      player_details['throws'] = cell_text(cells[4]).upcase
      player_details['age'] = cell_text(cells[5]).to_i
      contract_data['percent_active'] =  cell_text(cells[6]).to_i
      contract_data['percent_disabled'] =  cell_text(cells[7]).to_i
      contract_data['salary'] =  cell_text(cells[8]).to_i
      player_details['contract_data'] = contract_data
      hashkey = keyme(player_details['name'],player_details['position'])
      self.roster[hashkey] = player_details
    end
  end

  def process_batting_table
    # TODO
  end

  def process_pitching_table
    # TODO
  end

  def process_fielding_table
    # TODO
  end


end