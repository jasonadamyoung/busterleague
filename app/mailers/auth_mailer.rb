class AuthMailer < ApplicationMailer
  def create_mail(options = {})
    mail(options) do |format|
      format.text
    end
  end

  def token(options = {})
    @recipient = options[:recipient]
    @subject = "#{@recipient.nickname} : Here is your login email"

    if(!@recipient.email.blank?)
      return_email = create_mail(to: @recipient.email, subject: @subject)
    end

    return_email
  end

end
