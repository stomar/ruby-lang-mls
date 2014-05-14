require "pony"


# Mails requests via SMTP.
class MLMailer

  def initialize(options)
    @username     = options[:username]
    @password     = options[:password]
    @smtp_address = options[:smtp_address]
    @smtp_port    = options[:smtp_port]

    Pony.options = {
      :subject => '',
      :sender => @username,
      :via => :smtp,
      :via_options => {
        :user_name      => @username,
        :password       => @password,
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
