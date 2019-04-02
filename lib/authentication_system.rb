# Copyright 2011 Jason Adam Young <jay@outfielding.net>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
module AuthenticationSystem

  protected

  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights
  def authorize?(checkowner)
    if not checkowner
      return false
    else
      return true
    end
  end


  def signin_required
    if session[:ownerid]
      checkowner = Owner.where(id: session[:ownerid]).first
      if (authorize?(checkowner))
        if(!checkowner.primary_owner.blank?)
          @currentowner = checkowner.primary_owner
        else
          @currentowner = checkowner
        end
        return true
      end
    end

    # store current location so that we can
    # come back after the user logged in
    store_location
    access_denied
    return false
  end

  def signin_optional
    if session[:ownerid]
      checkowner = Owner.where(id: session[:ownerid]).first
      if (authorize?(checkowner))
        if(!checkowner.primary_owner.blank?)
          @currentowner = checkowner.primary_owner
        else
          @currentowner = checkowner
        end
      end
    end
    return true
  end


  def access_denied
    redirect_to(:controller=>:sessions, :action => :start)
  end


  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_location
    session[:return_to] = nil
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end

end
