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
    self.batting_data = {}
    self.process_tables
  end

  def process_tables
    tables_to_process = [{table_id: PRIMARY_TABLE, ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
     {table_id: SECONDARY_TABLE, ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
     {table_id: ANALYTICAL_TABLE, ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
     {table_id: LHP_TABLE, ignore_header_rows: 2, ignore_footer_rows: 0, prefix: 'l_'},
     {table_id: RHP_TABLE, ignore_header_rows: 2, ignore_footer_rows: 0, prefix: 'r_'}]

    tables_to_process.each do |pt|
      processed_data = self.process_table(table: self.tables[pt[:table_id]],
                                          ignore_header_rows: pt[:ignore_header_rows],
                                          ignore_footer_rows: pt[:ignore_footer_rows],
                                          prefix: pt[:prefix])
      processed_data.each do |key,tabledata|
        if(self.batting_data[key])
          self.batting_data[key] = self.batting_data[key].merge(tabledata)
        else
          self.batting_data[key] = tabledata
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
        label = header_cells[index]
        if(label == 'team')
          # skip blank team rows
          if table_cell.text.strip.empty? 
            next
          end 
        elsif(label == 'name')
          name = table_cell.text.strip
          if(name.last == '#' or name.last == '*')
            player_details['flag'] = name.last
            player_details['name'] = name[0..-2]
          else
            player_details['name'] = name
          end
        elsif(StatTools::BATTING_STAT_HEADERS[label])
          case StatTools::BATTING_STAT_HEADERS[label][:cast]
          when 'float'
            caster = 'to_f'
          when 'integer'
            caster = 'to_i'
          else
            caster = 'to_s'
          end
          player_details[label] = table_cell.text.strip.downcase.send(caster)
        else
          player_details[label] = table_cell.text.strip.downcase
        end
      end
      hashkey = keyme(player_details['name'],player_details['p'],player_details['team'])
      returnhash[hashkey] = player_details
    end
    returnhash
  end

  
end