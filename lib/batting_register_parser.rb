# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file


class BattingRegisterParser

  attr_accessor :htmlcontent
  attr_accessor :htmldoc
  attr_accessor :tables




  # Name	Team	P	Age	AVG	OBP	SPC	AB	H	2B	3B	HR	R	RBI	HBP	BB	K	SB	CS
  # Name	Team	P	Age	GS	PA	SH	SF	GDP	OPS	RC	RC27	ISO	TAVG	SEC	EBH	TB
  # Name	Team	P	Age	PA/G	AB/G	BIP	IPAVG	TBW	TBW/PA	TBWH	TBWH/PA	K/BB
  # Left
  # Name	Team	P	Age	AVG	OBP	SPC	OPS	AB	H	2B	3B	HR	RBI	BB	K
  # Right
  # Name	Team	P	Age	AVG	OBP	SPC	OPS	AB	H	2B	3B	HR	RBI	BB	K

  PRIMARY_TABLE = 0
  SECONDARY_TABLE = 1
  ANALYTICAL_TABLE = 2
  LHP_TABLE = 3
  RHP_TABLE = 4




  def initialize(htmlcontent)
    self.htmldoc = Nokogiri::HTML(htmlcontent)
    self.tables = self.htmldoc.search('table')
    self.process_tables 
  end

  def process_tables
    self.process_contract_table
  end

  def process_primary_table
    self.roster = {}
    primary_table = self.tables[CONTRACT_TABLE]
    rows = contract_table.search('tr')
    # attributes
    # S	Name	P	Bats	T	Age	%Act	%Dis	Salary	Year
    # ignore first three (header) and last (total) rows
    rows[3..-2].each do |row|
      cells = row.search('td')
      player_details = {}
      status = cells[0].text.strip
      player_details['status'] = (status == 'f') ? 'farmed' : 'active'
      player_details['name'] = cells[1].text.strip
      player_details['position'] = cells[2].text.strip.downcase
      player_details['bats'] = cells[3].text.strip.downcase
      player_details['throws'] = cells[4].text.strip.upcase
      player_details['age'] = cells[5].text.strip.to_i
      player_details['percent_active'] =  cells[6].text.strip.to_i
      player_details['percent_disabled'] =  cells[7].text.strip.to_i
      player_details['salary'] =  cells[8].text.strip.to_i
      roster[player_details['name']] = player_details
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