# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class SessionsController < ApplicationController

  def start
    if(params[:email].present?)
      findowner = Owner.where(email: params[:email]).first
      if(!findowner)
        flash.now[:error] = 'That email address is not registered.'
      else
        SlackIt.post(message: "#{findowner.nickname} requested a login link")
        AuthMailer.token(recipient: findowner).deliver
        return redirect_to(notice_url)
      end
    end
  end

  def notice
  end

  def token
    if(params[:token].blank?)
      return render(template: 'sessions/invalid_token')
    end

    if(!(owner = Owner.where(token: params[:token]).first))
      return render(template: 'sessions/invalid_token')
    else
      owner.login
      session[:ownerid] = owner.id
      @currentowner = owner.id
      SlackIt.post(message: "#{owner.nickname} has signed into #{Settings.location}")
      owner.clear_token
      return redirect_back_or_default(home_url)
    end
  end


  def end
    @currentowner = nil
    session[:ownerid] = nil
    flash[:success] = "You have successfully logged out."
    return redirect_to(root_url)
  end


end
