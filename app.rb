# frozen_string_literal: true

# ruby-lang.org mailing list service/subscriber
#
# project home page: https://github.com/stomar/ruby-lang-mls
#
# Copyright (C) 2013-2018 Marcus Stollsteimer
#
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

require "sinatra/base"

require_relative "lib/mls"

ENV["TZ"] = "UTC"

SENDER_EMAIL = ENV['SENDER_EMAIL']
SMTP_USER    = ENV['SMTP_USER']
SMTP_PASSWORD = ENV['SMTP_PASSWORD']
SMTP_ADDRESS = ENV['SMTP_SERVER'] || ''
SMTP_PORT    = ENV['SMTP_PORT'] || '587'
NO_CONFIRM   = ENV['NO_CONFIRM'] == 'true'
NO_LOGS      = ENV['NO_LOGS'] == 'true'
DATABASE_URL = ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db"


begin
  DataMapper.setup(:default, DATABASE_URL)
  DataMapper.auto_upgrade!
  DB = true
rescue StandardError, LoadError => e
  warn "Error initializing database: #{e.class}: #{e}"
  DB = false
end


class App < Sinatra::Base

  set :environment, :production

  configure do
    set :mailer, MLS::Mailer.new(
                   :sender_email  => SENDER_EMAIL,
                   :smtp_user     => SMTP_USER,
                   :smtp_password => SMTP_PASSWORD,
                   :smtp_address  => SMTP_ADDRESS,
                   :smtp_port     => SMTP_PORT
                 )
    set :logger, MLS::Logger.new(:no_logs => NO_LOGS)
    set :stats,  MLS::StatsHandler.new

    messages = {
      :success => {
        :header => 'Confirmation',
        :text   => 'Your request has been accepted. '.dup <<
                   'To complete your request, please follow the instructions ' <<
                   'in the email you should receive shortly.'
      },
      :invalid => {
        :header => 'Invalid request',
        :text   => 'Your request is invalid. '.dup <<
                   'Please make sure that you filled out all fields.'
      },
      :error => {
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
    @ml_request = MLS::Request.new(params)

    if @ml_request.valid?
      begin
        settings.mailer.mail(@ml_request.mail_options)
        status = :success
        settings.logger.log(@ml_request.list, @ml_request.action)
        settings.stats.increment(@ml_request.list, @ml_request.action)
      rescue => e
        status = :error
        settings.logger.log_error(@ml_request.list, @ml_request.action, e)
      end
    else
      status = :invalid
      settings.logger.log_invalid(@ml_request.list, @ml_request.action)
    end

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
    settings.logger.recent_entries.join("\n") << "\n"
  end
end
