require 'dm-core'
require 'dm-migrations'

DATABASE_URL = ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db"

class Log
  include DataMapper::Resource

  property :id,        Serial
  property :timestamp, DateTime
  property :list,      String, :length => 9
  property :action,    String, :length => 11
  property :status,    String, :length => 7
  property :exception, String, :length => 35
  property :entry,     String, :length => 120
end

DataMapper.finalize
DataMapper.setup(:default, DATABASE_URL)
DataMapper.auto_upgrade!

Log.each do |entry|

  data = entry.entry
  next unless data

  /\A\[(?<time>.+)\] STAT +(?<status>\w+) +\((?<list>[^,]*), +(?<action>[^)]*)\)( +(?<error>.+))?\z/ =~ data
  time = Time.parse(time).utc

  entry.update(
    :entry => nil,
    :timestamp => time,
    :status => status,
    :list => list,
    :action => action,
    :exception => error
  )
end

adapter = DataMapper.repository(:default).adapter
adapter.execute("ALTER TABLE logs DROP COLUMN entry;")
