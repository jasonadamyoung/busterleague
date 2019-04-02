class AdminConstraint
  def matches?(request)
    return false unless request.session[:ownerid]
    owner = Owner.find(request.session[:ownerid])
    owner && owner.is_admin?
  end
end
