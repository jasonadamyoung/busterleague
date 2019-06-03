class UpdateMailerPreview < ActionMailer::Preview
  def update_email
    UpdateMailer.with(owner: Owner.first).update_email
  end

end