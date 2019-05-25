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


  def ss
    # all the work for this is actually done in the set_season before_action
    if(!params[:currenturi].nil?)
      return redirect_to(Base64.decode64(params[:currenturi]))
    else
      return redirect_to(root_url)
    end
  end
  
end
