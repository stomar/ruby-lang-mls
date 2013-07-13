# ruby-lang.org mailing list service/subscriber
#
# project home page: https://github.com/stomar/ruby-lang-mls
#
# Copyright (C) 2013 Marcus Stollsteimer
#
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

require 'sinatra/base'
require 'pony'

require './lib/mllogger'

USERNAME     = ENV['SMTP_USERNAME']
PASSWORD     = ENV['SMTP_PASSWORD']
SMTP_ADDRESS = ENV['SMTP_SERVER']
SMTP_PORT    = ENV['SMTP_PORT'] || '587'
NO_CONFIRM   = ENV['NO_CONFIRM'] == 'true'
NO_LOGS      = ENV['NO_LOGS'] == 'true'
DATABASE_URL = ENV['DATABASE_URL']


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
    !@first_name.strip.empty? &&
    !@last_name.strip.empty? &&
    !@email.strip.empty? &&
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

  set :environment, :production

  configure do
    set :mllogger, MLLogger.new(
                     :database_url => DATABASE_URL || "sqlite3://#{Dir.pwd}/development.db",
                     :no_logs      => NO_LOGS
                   )

    messages = {
      :success => {
        :log    => 'Success',
        :header => 'Confirmation',
        :text   => 'Your request has been accepted. ' <<
                   'To complete your request, please follow the instructions ' <<
                   'in the email you should receive shortly.'
      },
      :invalid => {
        :log    => 'Invalid',
        :header => 'Invalid request',
        :text   => 'Your request is invalid. ' <<
                   'Please make sure that you filled out all fields.'
      },
      :error => {
        :log    => 'Error',
        :header => 'Error',
        :text   => 'Sorry, an error occurred during processing of your request.'
      },
    }

    set :messages, messages

    set :status_codes, { :success => 200, :invalid => 400, :error => 500 }
  end

  def escape(text)
    Rack::Utils.escape_html(text)
  end

  get '/' do
    erb :index
  end

  post '/submit' do
    @ml_request = MLRequest.new(params)
    time        = Time.now
    log_info    = { :list => @ml_request.list, :action => @ml_request.action }

    if @ml_request.valid?
      begin
        Pony.mail(@ml_request.mail_options)
        status = :success
      rescue => e
        log_info[:exception] = e
        status = :error
      end
    else
      status = :invalid
    end

    log_info[:status] = settings.messages[status][:log]
    settings.mllogger.log(time, log_info)

    @header  = settings.messages[status][:header]
    @message = settings.messages[status][:text]

    if NO_CONFIRM
      redirect back
    else
      status settings.status_codes[status]
      erb :confirmation
    end
  end

  get '/logs/?' do
    content_type :txt
    settings.mllogger.recent_entries
  end
end
