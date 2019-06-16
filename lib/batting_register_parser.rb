# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file


class BattingRegisterParser
  include ParserUtils

  attr_accessor :htmlcontent
  attr_accessor :htmldoc
  attr_accessor :tables
  attr_accessor :batting_data
  attr_accessor :batting_data_team

  # Name	Team	P	Age	AVG	OBP	SPC	AB	H	2B	3B	HR	R	RBI	HBP	BB	K	SB	CS
  # Name	Team	P	Age	GS	PA	SH	SF	GDP	OPS	RC	RC27	ISO	TAVG	SEC	EBH	TB
  # Name	Team	P	Age	PA/G	AB/G	BIP	IPAVG	TBW	TBW/PA	TBWH	TBWH/PA	K/BB
  # Left
  # Name	Team	P	Age	AVG	OBP	SPC	OPS	AB	H	2B	3B	HR	RBI	BB	K
  # Right
  # Name	Team	P	Age	AVG	OBP	SPC	OPS	AB	H	2B	3B	HR	RBI	BB	K

  CORE_TABLES = 
  [{table_label: 'primary', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
    {table_label: 'secondary', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
    {table_label: 'analytical', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
   {table_label: 'lhb', ignore_header_rows: 2, ignore_footer_rows: 0, prefix: 'l_'},
   {table_label: 'rhb', ignore_header_rows: 2, ignore_footer_rows: 0, prefix: 'r_'}]
  

  def initialize(htmlcontent)
    self.htmldoc = Nokogiri::HTML(htmlcontent)
    self.tables = self.htmldoc.search('table')
    self.batting_data = {}
    self.batting_data_team = {}
    self.process_tables
  end

  def process_tables
     CORE_TABLES.each_with_index do |pt,index|
        processed_data = self.process_table(table: self.tables[index],
                                          ignore_header_rows: pt[:ignore_header_rows],
                                          ignore_footer_rows: pt[:ignore_footer_rows],
                                          prefix: pt[:prefix])
      processed_data.each do |key,tabledata|
        if(tabledata['name'] and tabledata['name'] == 'Total')
          if(!self.batting_data_team.empty?)
            self.batting_data_team = self.batting_data_team.merge(tabledata)
          else
            self.batting_data_team = tabledata
          end
        else
          if(self.batting_data[key])
            self.batting_data[key] = self.batting_data[key].merge(tabledata)
          else
            self.batting_data[key] = tabledata
          end
        end
      end
    end
  end

  def process_table(options = {})
    returnhash = {}
    ignore_header_rows = options[:ignore_header_rows]
    ignore_footer_rows = options[:ignore_footer_rows]
    table = options[:table]
    prefix = options[:prefix].nil? ? '' : options[:prefix]

    rows = table.search('tr')
    header_cells = rows[ignore_header_rows].search('td').map{|c| convert_field(c.text.strip,prefix)}
    rows[(ignore_header_rows+1)..((ignore_footer_rows+1)*-1)].each do |row|
      cells = row.search('td')
      player_details = {}
      cells.each_with_index do |table_cell,index|
        label = label_translation(header_cells[index])
        if(label == 'name')
          name = table_cell.text.strip
          if(name.last == '#' or name.last == '*')
            player_details['flag'] = name.last
            player_details['name'] = name_fixer(name[0..-2])
          else
            player_details['name'] = name_fixer(name)
          end
        else
          player_details[label] = convert_numeric(table_cell.text.strip.downcase)
        end
        # &nbsp remover
        player_details[label] = '' if(player_details[label] == '&nbsp')
      end
      hashkey = keyme(player_details['name'],player_details['p'],player_details['team'])
      returnhash[hashkey] = player_details
    end
    returnhash
  end

  
end