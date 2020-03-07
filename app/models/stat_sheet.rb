# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'zip'

class StatSheet < ApplicationRecord
  include SheetUploader::Attachment(:sheet)

  belongs_to :owner
  after_create :check_for_processing


  def check_for_processing
    if(Settings.redis_enabled)
      # let the processing be manual post-create if we aren't backgrounding
      self.queue_processdata
    end
    true
  end

  def queue_processdata
    if(!Settings.redis_enabled)
      self.processdata
    else
      self.class.delay_for(5.seconds).delayed_processdata(self.id)
    end
  end

  def self.delayed_processdata(record_id)
    if(record = find_by_id(record_id))
      record.processdata
    end
  end


  def processdata
    data_to_process = self.get_xlsx_data
    first_row = data_to_process.shift
    if(!first_row['whip'].nil?)
      data_to_process.each do |datahash|
        RealPitchingStat.create_or_update_stat(datahash)
      end
    else
      data_to_process.each do |datahash|
        RealBattingStat.create_or_update_stat(datahash)
      end
    end
  end


  def fix_xlsx_header_field(field)
    # replace chars
    returnfield = field.downcase.gsub('/','_per_').gsub('+','plus').gsub('-','_').gsub(' ','_')
    case returnfield
    when 'team'
      'team_string'
    when 'pos'
      'position'
    when 'b'
      'bats'
    when 't'
      'throws'
    else
      returnfield
    end
  end

  def get_xlsx_data
    returndata = []
    sheet_path = self.sheet.storage.path(self.sheet.id).to_s
    xlsx = Roo::Spreadsheet.open(sheet_path)
    # get the first sheet name
    sheet = xlsx.sheet(xlsx.sheets.first)
    parsed_data = sheet.parse(headers: true,clean: true)
    parsed_data.each do |row|
      newrow = {}
      row.each do |key, value|
        newrow[fix_xlsx_header_field(key)] = value
      end
      returndata << newrow
    end
    returndata
  end


end
