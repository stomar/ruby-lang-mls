require_relative "mllogger"


# Removes log entries for successful requests.
class MLLogCleaner

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

  def cleanup_all
    unless @db
      warn "Database not available"
      return
    end

    entries = Log.all(:status => "Success")

    entries.each do |entry|
      puts "Removing entry #{entry.id} (#{entry.timestamp})"
      entry.destroy
    end
  end
end
