require "rake/testtask"

MAILER_API_URL = ENV["MAILER_API_URL"]
MAILER_API_KEY = ENV["MAILER_API_KEY"]
ADMIN_EMAIL  = ENV["ADMIN_EMAIL"]


task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
  t.ruby_opts << "-rubygems"
  t.libs << "."
  t.verbose = true
  t.warning = false
end


desc "List all log entries"
task :logs do
  require_relative "app"

  mllogger = MLLogger.new
  puts mllogger.entries.join("\n") << "\n"
end

namespace :logs do

  desc "List log entries for failed requests"
  task :errors do
    require_relative "app"

    mllogger = MLLogger.new
    puts mllogger.errors.join("\n") << "\n"
  end

  desc "Cleanup logs"
  task :cleanup do
    require_relative "app"
    require_relative "lib/mllogcleaner"

    mllogcleaner = MLLogCleaner.new
    mllogcleaner.cleanup_all
  end
end


desc "List all daily stats entries"
task :stats do
  require_relative "app"

  mldailystats = MLStatsHandler.new
  puts mldailystats.entries.join("\n") << "\n"
end


namespace :mailer do

  desc "List email service stats"
  task :stats do
    require_relative "lib/mlmailerstats"

    if MAILER_API_URL && MAILER_API_KEY
      stats = MLMailerStats.new(
                :api_url => MAILER_API_URL,
                :api_key => MAILER_API_KEY
              )
      puts stats.get
    else
      warn "MAILER_API_URL or MAILER_API_KEY not defined"
    end
  end

  desc "Test email delivery"
  task :test do
    require_relative "app"

    if ADMIN_EMAIL
      mailer = MLMailer.new(
                 :sender_email => SENDER_EMAIL,
                 :smtp_user    => SMTP_USER,
                 :smtp_password => SMTP_PASSWORD,
                 :smtp_address => SMTP_ADDRESS,
                 :smtp_port    => SMTP_PORT
               )

      mailer.mail(
        :to      => ADMIN_EMAIL,
        :from    => ADMIN_EMAIL,
        :subject => "Test email for ruby-lang-mls",
        :body    => "This email has been sent with `rake mailer_test'."
      )
    else
      warn "ADMIN_EMAIL not defined"
    end
  end
end
