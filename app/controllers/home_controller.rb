# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'rmagick'

class HomeController < ApplicationController

  def index
    return redirect_to(standings_url(season: @season))
  end

  def seasons
  end



  def teamlogo
    @filename = params[:filename]
    @team = Team.where(id: params[:id]).first
    (width,height) = [100,100]
    img, data = Magick::Image.from_blob(@team.svglogo) {
      self.format = 'SVG'
      self.background_color = 'transparent'
    }
    thumb = img.resize(width, height)
    thumb.format = 'png'
    thumb.background_color = "Transparent"
    respond_to do |format|
      format.png  { 
        send_data(thumb.to_blob,
                   :type  => 'image/png',
                   :filename => @filename,
                   :disposition => 'inline') 
      }
    end
  end 



end