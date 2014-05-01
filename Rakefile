require 'rake/testtask'

DATABASE_URL = ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db"
MAILER_API_URL = ENV["MAILER_API_URL"]
MAILER_API_KEY = ENV["MAILER_API_KEY"]


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
