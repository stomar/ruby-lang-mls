# Removes log entries for successful requests.
class MLLogCleaner

  def initialize
    @db = DB
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
