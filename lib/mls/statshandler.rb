# frozen_string_literal: true

require "date"


module MLS

  # Updates/returns daily stats entries.
  class StatsHandler

    def initialize
      @db = DB
    end

    def increment(list, action, timestamp: Time.now.utc)
      unless @db
        warn "Database not available"
        return
      end

      date = timestamp.to_date

      entry = DailyStats.find_or_create(date: date)
      entry.increment(list, action)
    end

    def entries
      return ["No stats available"]  unless @db

      DailyStats.by_date.all
    end
  end
end
