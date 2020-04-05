# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'zip'

class StatSheet < ApplicationRecord
  include SheetUploader::Attachment(:sheet)

  belongs_to :owner

  def fix_xlsx_header_field(field)
    # position fields
    position_fields = ['c','1b','2b','3b','ss','lf','cf','rf']
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
    when *position_fields
      "pos_#{returnfield}"
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
