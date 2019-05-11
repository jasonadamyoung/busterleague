# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class BattingStat < ApplicationRecord

  # belongs_to :player
  # belongs_to :team

  def self.register_url(season)
    base_url = "#{Settings.web_reports_base_url}/#{season}"
    "#{base_url}/orgbatreg.htm"
  end

  def self.get_register_html(season)
    response = RestClient.get(self.register_url(season))
    if(!response.code == 200)
      return nil
    end
    response.to_str
  end

end

