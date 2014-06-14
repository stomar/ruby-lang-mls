require "dm-core"
require "dm-migrations"


class DailyStats
  include DataMapper::Resource

  property :id,         Serial
  property :date,       Date,    :required => true
  property :talk_subsc, Integer, :default => 0
  property :talk_unsub, Integer, :default => 0
  property :core_subsc, Integer, :default => 0
  property :core_unsub, Integer, :default => 0
  property :doc_subsc,  Integer, :default => 0
  property :doc_unsub,  Integer, :default => 0
  property :cvs_subsc,  Integer, :default => 0
  property :cvs_unsub,  Integer, :default => 0

  def self.headers
    %w{date talk_subsc talk_unsub core_subsc core_unsub
       doc_subsc doc_unsub cvs_subsc cvs_unsub}.join(",")
  end

  def to_string
    [date, talk_subsc, talk_unsub, core_subsc, core_unsub,
     doc_subsc, doc_unsub, cvs_subsc, cvs_unsub].map(&:to_s).join(",")
  end
end

DataMapper.finalize


# Returns daily stats entries.
class MLDailyStats

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

  def entries(limit: nil)
    return ["No stats available"]  unless @db

    if limit
      entries = DailyStats.all(:order => [:date.desc], :limit => limit).to_a.reverse
    else
      entries = DailyStats.all(:order => [:date.asc])
    end

    [DailyStats.headers] + entries.map(&:to_string)
  end
end
