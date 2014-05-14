require 'rake/testtask'

ENV["TZ"] = "UTC"

USERNAME     = ENV['SMTP_USERNAME']
PASSWORD     = ENV['SMTP_PASSWORD']
SMTP_ADDRESS = ENV['SMTP_SERVER'] || ''
SMTP_PORT    = ENV['SMTP_PORT'] || '587'
DATABASE_URL = ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db"
MAILER_API_URL = ENV["MAILER_API_URL"]
MAILER_API_KEY = ENV["MAILER_API_KEY"]
ADMIN_EMAIL  = ENV["ADMIN_EMAIL"]


task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = 'test/**/test_*.rb'
  t.ruby_opts << '-rubygems'
  t.libs << '.'
  t.verbose = true
  t.warning = false
end


desc 'List all log entries'
task :logs do
  require './lib/mllogger'

  mllogger = MLLogger.new(:database_url => DATABASE_URL)

  puts mllogger.entries.join("\n") << "\n"
end


desc 'List email service stats'
task :mailer_stats do
  require './lib/mlmailerstats'

  stats = MLMailerStats.new(
            :api_url => MAILER_API_URL,
            :api_key => MAILER_API_KEY
          )

  puts stats.get
end


desc "Test email delivery"
task :mailer_test do
  require "./lib/mlmailer"

  if ADMIN_EMAIL
    mailer = MLMailer.new(
               :username     => USERNAME,
               :password     => PASSWORD,
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
