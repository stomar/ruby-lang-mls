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
    !@first_name.empty? && !@last_name.empty? && !@email.empty? &&
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

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  post '/submit' do
    @ml_request = MLRequest.new(params)

    if @ml_request.valid?
      begin
        Pony.mail(@ml_request.mail_options)
        @message =  'Your request has been accepted. '
        @message << 'You should receive a confirmation email shortly.'
      rescue
        @message = 'Sorry, an error occurred during processing of your request.'
      end
    else
      @message =  'Your request is invalid. '
      @message << 'Please make sure that you filled out all fields.'
    end

    if NO_CONFIRM
      redirect back
    else
      erb :confirmation
    end
  end
end
