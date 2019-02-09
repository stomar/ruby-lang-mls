# frozen_string_literal: true

require "date"


# Returns daily stats entries.
module MLS
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

      entry = DailyStats.first_or_create(date: date)
      entry.increment(list, action)
    end

    def entries(limit: nil)
      return ["No stats available"]  unless @db

      if limit
        entries = DailyStats.all(order: [:date.desc], limit: limit).to_a.reverse
      else
        entries = DailyStats.all(order: [:date.asc])
      end

      [DailyStats.headers] + entries.map(&:to_string)
    end
  end
end
