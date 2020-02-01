# frozen_string_literal: true

module MLS

  # Logs subscribe/unsubscribe events to stderr and database.
  class Logger

    def initialize(options = {})
      @no_logs = options.fetch(:no_logs, false)
      @db = DB

      warn "Logging to stdout only"  unless @db
    end

    def log(list, action)
      add_to_log(list, action, "Success")
    end

    def log_invalid(list, action)
      add_to_log(list, action, "Invalid")
    end

    def log_error(list, action, exception)
      add_to_log(list, action, "Error", exception)
    end

    def entries(limit: nil)
      return ["No logs available"]  unless @db

      entries = if limit
                  Log.reverse(:timestamp).limit(limit).to_a.reverse
                else
                  Log.order(:timestamp)
                end

      entries.map(&:to_s)
    end

    def recent_entries
      entries(limit: 40)
    end

    def errors(limit: nil)
      return ["No logs available"]  unless @db

      entries = if limit
                  Log.exclude(status: "Success").reverse(:timestamp).limit(limit).to_a.reverse
                else
                  Log.exclude(status: "Success").order(:timestamp)
                end

      entries.map(&:to_s)
    end

    private

    def add_to_log(list, action, status, exception = nil)
      return  if @no_logs

      time = Time.now.utc
      time_string = time.strftime("%Y-%m-%d %H:%M:%S %z")

      warn "[#{time_string}] #{list}, #{action}, #{status}"
      warn "#{exception.class}: #{exception}"  if exception

      return  unless @db

      Log.create(
        timestamp: time,
        status: status,
        list: list,
        action: action,
        exception: exception ? exception.class.to_s : nil
      )
    end
  end
end
