class UpdateMailer < ApplicationMailer
  layout 'mailer'
  helper :teams

  def create_mail(options = {})
    make_bootstrap_mail(options) do |format|
      format.html
      # format.text
    end
  end

  def update_email
    @owner = params[:owner]
    @team = @owner.team
    @teamrecord = @team.record_for_season(Game.current_season)
    @subject = "#{@owner.nickname} : Your BusterLeague Update"

    if(Settings.busterleague_location != 'busterleague-prod' )
      return_email = create_mail(to: Settings.email_bcc_address, subject: @subject)
    elsif(!@owner.email.blank?)
      return_email = create_mail(to: @owner.email, subject: @subject)
    end

    return_email
  end

end
