# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file
require 'rmagick'

class WelcomeController < ApplicationController

  def home
    return redirect_to(standings_url(season: @season))
  end

  def index
  end

  def show
  end

  def dmb
  end

  def awards
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



  def ss
    # all the work for this is actually done in the set_season before_action
    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(root_url)
    end
  end
  
end
