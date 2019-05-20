# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'csv'

class RealBattingStat < ApplicationRecord

  belongs_to :roster, optional: true
  has_one :player, through: :roster
  belongs_to :team


  def self.import_from_csv(filename)
    import_file = File.open(filename)
    CSV::HeaderConverters[:slash_to_per] = lambda do |field|
      field.gsub('/','_per_')
    end
    CSV::HeaderConverters[:plus_converter] = lambda do |field|
      field.gsub('+','plus')
    end
    CSV::HeaderConverters[:dash_to_underscore] = lambda do |field|
      field.gsub('-','_')
    end
    CSV::HeaderConverters[:space_to_underscore] = lambda do |field|
      field.gsub(' ','_')
    end       
    csv = CSV.new(import_file, :headers => true, :header_converters => [:downcase,:slash_to_per,:plus_converter,:dash_to_underscore,:space_to_underscore], :converters => [:all])
    data = csv.to_a.map {|row| row.to_hash }
    data
  end

end
