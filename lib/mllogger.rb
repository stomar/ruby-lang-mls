require 'dm-core'
require 'dm-migrations'


class Log
  include DataMapper::Resource

  property :id,    Serial
  property :entry, String, :length => 120
end

DataMapper.finalize


# Logs subscribe/unsubscribe events to stderr and database.
class MLLogger

  def initialize(options)
    @database_url = options[:database_url]
    @no_logs      = options.fetch(:no_logs, false)
    @db = nil

    if @database_url
      begin
        DataMapper.setup(:default, @database_url)
        DataMapper.auto_upgrade!
        @db = true
      rescue StandardError, LoadError => e
        warn "Error initializing database: #{e.class}: #{e}"
        warn 'Logging to stdout only'
        @db = nil
      end
    end
  end

  def log(time, info)
    return  if @no_logs

    status    = info[:status]
    list      = info[:list]
    action    = info[:action]
    exception = info[:exception]

    entry =  "#{time.strftime('[%Y-%m-%d %H:%M:%S %z]')}"
    entry << " STAT  " << status.ljust(7)
    entry << " (" << (list + ',').ljust(10) << " #{action})"
    entry << " #{exception.class}"  if exception

    warn entry
    warn "#{exception.class}: #{exception}"  if exception
    Log.create(:entry => entry)  if @db
  end

  def entries
    return "No logs available\n"  unless @db

    entries = Log.all.map(&:entry)

    entries.sort.join("\n") << "\n"
  end

  def recent_entries
    return "No logs available\n"  unless @db

    entries = Log.all(:order => [:entry.desc], :limit => 40).map(&:entry)

    entries.sort.join("\n") << "\n"
  end
end
