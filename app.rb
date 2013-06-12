# ruby-lang.org mailing list service/subscriber
#
# project home page: https://github.com/stomar/ruby-lang-mls
#
# Copyright (C) 2013 Marcus Stollsteimer
#
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

require 'sinatra/base'
require 'pony'

USERNAME     = ENV['SMTP_USERNAME']
PASSWORD     = ENV['SMTP_PASSWORD']
SMTP_ADDRESS = ENV['SMTP_SERVER']
SMTP_PORT    = ENV['SMTP_PORT'] || '587'
NO_CONFIRM   = ENV['NO_CONFIRM'] == 'true'
NO_LOGS      = ENV['NO_LOGS'] == 'true'


Pony.options = {
  :subject => '',
  :sender => USERNAME,
  :via => :smtp,
  :via_options => {
    :user_name      => USERNAME,
    :password       => PASSWORD,
    :address        => SMTP_ADDRESS,
    :port           => SMTP_PORT,
    :authentication => :plain,
    :enable_starttls_auto => true,
  }
}


class MLRequest

  attr_reader :list, :first_name, :last_name, :email, :action

  ACTIONS = ['subscribe', 'unsubscribe']
  LISTS   = ['ruby-talk', 'ruby-core', 'ruby-doc', 'ruby-cvs']

  def initialize(params)
    @list = params[:list] || ''
    @first_name = params[:first_name] || ''
    @last_name = params[:last_name] || ''
    @email = params[:email] || ''
    @action = params[:action] || ''
  end

  def valid?
    @first_name =~ /\A[a-zA-Z]+\Z/ &&
    @last_name  =~ /\A[a-zA-Z]+\Z/ &&
    !@email.empty? &&
    LISTS.include?(@list) && ACTIONS.include?(@action)
  end

  def mail_options
    {
      :to   => "#{@list}-ctl@ruby-lang.org",
      :from => @email,
      :body => "#{@action} #{@first_name} #{@last_name}"
    }
  end
end


class App < Sinatra::Base

  helpers do
    def escape(text)
      Rack::Utils.escape_html(text)
    end

    def log(entry)
      return  if NO_LOGS
      warn entry
    end
  end

  get '/' do
    erb :index
  end

  post '/submit' do
    @ml_request = MLRequest.new(params)
    log_data    = "#{@ml_request.list}, #{@ml_request.action}"
    time        = Time.now.strftime('[%Y-%m-%d %H:%M:%S]')

    if @ml_request.valid?
      begin
        Pony.mail(@ml_request.mail_options)
        @status  =  'Confirmation'
        @message =  'Your request has been accepted. '
        @message << 'You should receive a confirmation email shortly.'
        log "#{time} STAT  Success (#{log_data})"
      rescue
        @status  = 'Error'
        @message = 'Sorry, an error occurred during processing of your request.'
        log "#{time} STAT  Error (#{log_data})"
      end
    else
      @status  =  'Invalid request'
      @message =  'Your request is invalid. '
      @message << 'Please make sure that you filled out all fields.'
      log "#{time} STAT  Invalid (#{log_data})"
    end

    if NO_CONFIRM
      redirect back
    else
      erb :confirmation
    end
  end
end
