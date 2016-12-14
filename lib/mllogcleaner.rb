require "date"
require_relative "mllogger"
require_relative "mldailystats"


# Migrates log entries to daily stats table.
class MLLogCleaner

  DAYS_TO_KEEP = 30

  def initialize(options)
    @database_url = options[:database_url]
    @db = nil

    if @database_url
      begin
        DataMapper.setup(:default, @database_url)
        DataMapper.auto_upgrade!
        @db = true
      rescue StandardError, LoadError => e
        warn "Error initializing database: #{e.class}: #{e}"
        @db = nil
      end
    end

    @stats = MLDailyStats.new(:database_url => @database_url)
  end

  def migrate_all
    unless @db
      warn "Database not available"
      return
    end

    entries = Log.all(:status => "Success", :timestamp.lt => Date.today - DAYS_TO_KEEP)

    entries.each do |entry|
      puts "Migrating entry #{entry.id} (#{entry.timestamp})"

      @stats.increment(entry.list, entry.action, timestamp: entry.timestamp)
      entry.destroy
    end
  end
end
