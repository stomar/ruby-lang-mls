# frozen_string_literal: true

require "pony"


# Mails requests via SMTP.
module MLS
  class Mailer

    def initialize(options)
      @sender_email  = options[:sender_email]
      @smtp_user     = options[:smtp_user]
      @smtp_password = options[:smtp_password]
      @smtp_address  = options[:smtp_address]
      @smtp_port     = options[:smtp_port]

      Pony.options = {
        :subject => '',
        :from => @sender_email,
        :via => :smtp,
        :via_options => {
          :user_name      => @smtp_user,
          :password       => @smtp_password,
          :address        => @smtp_address,
          :port           => @smtp_port,
          :authentication => :plain,
          :enable_starttls_auto => true
        }
      }
    end

    def mail(options)
      Pony.mail(options)
    end
  end
end
