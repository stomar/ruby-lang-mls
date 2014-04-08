require 'dm-core'
require 'dm-migrations'


class Log
  include DataMapper::Resource

  property :id,        Serial
  property :timestamp, DateTime, :required => true
  property :list,      String, :length => 9,  :required => true
  property :action,    String, :length => 11, :required => true
  property :status,    String, :length => 7,  :required => true
  property :exception, String, :length => 35

  def entry
    msg =  timestamp.strftime('[%Y-%m-%d %H:%M:%S %z]')
    msg << " STAT  " << status.ljust(7)
    msg << " (#{(list + ',').ljust(10)} #{action})"
    msg << " #{exception}"  if exception

    msg
  end
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

    warn time.strftime('[%Y-%m-%d %H:%M:%S %z]') + " #{list}, #{action}, #{status}"
    warn "#{exception.class}: #{exception}"  if exception
    Log.create(
      :timestamp => time,
      :status => status,
      :list => list,
      :action => action,
      :exception => exception ? exception.class.to_s : nil
    )  if @db
  end

  def entries
    return "No logs available\n"  unless @db

    entries = Log.all.map(&:entry)

    entries.sort.join("\n") << "\n"
  end

  def recent_entries
    return "No logs available\n"  unless @db

    entries = Log.all(:order => [:timestamp.desc], :limit => 40).map(&:entry)

    entries.sort.join("\n") << "\n"
  end
end
