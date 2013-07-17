require 'rake/testtask'

DATABASE_URL = ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db"


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

  puts mllogger.entries
end
