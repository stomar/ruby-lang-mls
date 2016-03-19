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
    return ["Database not available"]  unless @db

    entries = Log.all(:status => "Success", :timestamp.lt => Date.today - DAYS_TO_KEEP)

    entries.each do |entry|
      puts "Migrating entry #{entry.id} (#{entry.timestamp})"
      migrate_log_entry_to_daily_stats(entry)
    end
  end

  private

  def migrate_log_entry_to_daily_stats(log_entry)
    date = log_entry.timestamp.to_date
    column = extract_column_name_as_sym(log_entry)

    stats_entry = DailyStats.first_or_create(:date => date)
    increment_stats_column(stats_entry, column)

    log_entry.destroy
  end

  def extract_column_name_as_sym(log_entry)
    column_name = log_entry.list.gsub("ruby-","") + "_" + log_entry.action[0..4]

    column_name.to_sym
  end

  def increment_stats_column(stats_entry, column)
    new_value = stats_entry[column] + 1
    stats_entry.update(column => new_value)
  end
end
