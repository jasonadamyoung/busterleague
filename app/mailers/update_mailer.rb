class UpdateMailer < ApplicationMailer
  layout 'mailer'

  def create_mail(options = {})
    make_bootstrap_mail(options) do |format|
      format.html
      # format.text
    end
  end

  def update_email
    @owner = params[:owner]
    @subject = "#{@owner.nickname} : Your BusterLeague Update"

    if(!@owner.email.blank?)
      return_email = create_mail(to: @owner.email, subject: @subject)
    end

    return_email
  end

end