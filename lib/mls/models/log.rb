# frozen_string_literal: true

require "dm-core"
require "dm-migrations"


# Log model.
class Log

  include DataMapper::Resource

  property :id,        Serial
  property :timestamp, DateTime, required: true
  property :list,      String,   length: 9,  required: true
  property :action,    String,   length: 11, required: true
  property :status,    String,   length: 7,  required: true
  property :exception, String,   length: 35

  def to_string
    msg =  timestamp.strftime("[%Y-%m-%d %H:%M:%S %z] ")
    msg << status.ljust(7)
    msg << " (#{(list + ',').ljust(10)} #{action})"
    msg << " #{exception}"  if exception

    msg
  end
end
