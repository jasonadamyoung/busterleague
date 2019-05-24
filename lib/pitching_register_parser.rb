# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file


class PitchingRegisterParser
  include ParserUtils

  attr_accessor :htmlcontent
  attr_accessor :htmldoc
  attr_accessor :tables
  attr_accessor :pitching_data
  attr_accessor :table_type

  CORE_TABLES = 
  [{table_label: 'primary', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
   {table_label: 'secondary', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
   {table_label: 'analytical', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
   {table_label: 'start', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
   {table_label: 'relief', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil}]

   BATTING_TABLES = 
   [{table_label: 'primary', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
    {table_label: 'analytical', ignore_header_rows: 1, ignore_footer_rows: 0, prefix: nil},
    {table_label: 'lhb', ignore_header_rows: 2, ignore_footer_rows: 0, prefix: 'l_'},
    {table_label: 'rhb', ignore_header_rows: 2, ignore_footer_rows: 0, prefix: 'r_'}]
 

  def initialize(htmlcontent,table_type)
    self.htmldoc = Nokogiri::HTML(htmlcontent)
    self.tables = self.htmldoc.search('table')
    self.table_type = table_type
    self.pitching_data = {}
    self.process_tables
  end

  def process_tables
    case self.table_type
    when 'core_tables'
      tables_to_process = CORE_TABLES
    when 'batting_tables'
      tables_to_process = BATTING_TABLES
    else
      return nil
    end


    tables_to_process.each_with_index do |pt,index|
      processed_data = self.process_table(table: self.tables[index],
                                          ignore_header_rows: pt[:ignore_header_rows],
                                          ignore_footer_rows: pt[:ignore_footer_rows],
                                          prefix: pt[:prefix])
      processed_data.each do |key,tabledata|
        if(self.pitching_data[key])
          self.pitching_data[key] = self.pitching_data[key].merge(tabledata)
        else
          self.pitching_data[key] = tabledata
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
        elsif(label == 'ip')
          (int,frac) = table_cell.text.strip.downcase.split('.')
          player_details[label] = int.to_f + (frac.to_f / 3)      
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