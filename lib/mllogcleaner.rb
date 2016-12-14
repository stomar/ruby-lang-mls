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
  end

  def migrate_all
    unless @db
      warn "Database not available"
      return
    end

    entries = Log.all(:status => "Success", :timestamp.lt => Date.today - DAYS_TO_KEEP)

    entries.each do |entry|
      puts "Migrating entry #{entry.id} (#{entry.timestamp})"
      migrate_log_entry_to_daily_stats(entry)
    end
  end

  private

  def migrate_log_entry_to_daily_stats(entry)
    timestamp = entry.timestamp
    list = entry.list
    action = entry.action

    increment_stats(list, action, timestamp: timestamp)
    entry.destroy
  end

  def increment_stats(list, action, timestamp: Time.now.utc)
    date = timestamp.to_date
    column = column_as_sym(list, action)
    stats_entry = DailyStats.first_or_create(:date => date)
    increment_stats_column(stats_entry, column)
  end

  def column_as_sym(list, action)
    "#{list.gsub(/ruby-/,"")}_#{action[0..4]}".to_sym
  end

  def increment_stats_column(stats_entry, column)
    new_value = stats_entry[column] + 1
    stats_entry.update(column => new_value)
  end
end
