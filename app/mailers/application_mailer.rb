class ApplicationMailer < ActionMailer::Base
    default_url_options[:host] = Settings.urlwriter_host
    default from: Settings.email_from_address
    default bcc: Settings.email_bcc_address
    layout 'mailer'
end