# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file


class TransactionLogParser
  include ParserUtils

  attr_accessor :htmlcontent
  attr_accessor :htmldoc
  attr_accessor :transaction_table
  attr_accessor :transaction_data


  def initialize(htmlcontent)
    self.htmldoc = Nokogiri::HTML(htmlcontent)
    self.transaction_table = self.htmldoc.search('table').first
    self.transaction_data = {}
    self.process_table
  end


  def process_table(options = {})
    returnhash = {}
    rows = transaction_table.search('tr')
    # date,team,player,type,othteam,effdate,when
    rows[2..-1].each do |row|
      cells = row.search('td')
      log_details = {}
      log_details['date'] = Date.strptime(cells[0].text.strip, '%m/%d/%Y')
      log_details['team_string'] = cells[1].text.strip.upcase
      log_details['name'] = cells[2].text.strip
      log_details['action_text'] = cells[3].text.strip
      other_team_string = cells[4].text.strip
      if(!other_team_string.empty? and !(other_team_string == '&nbsp'))
        log_details['other_team_string'] = other_team_string.upcase
      end
      effective_date = cells[5].text.strip
      if(!effective_date.empty? and !(effective_date == '&nbsp'))
        log_details['effective_date'] = Date.strptime(effective_date, '%m/%d/%Y')
      end
      log_details['when_string'] = cells[6].text.strip.upcase
      hashkey = keyme(log_details['name'],log_details['date'].to_s,log_details['team_string'],log_details['action_text'])
      returnhash[hashkey] = log_details
    end
    self.transaction_data = returnhash
  end

end


