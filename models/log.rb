# frozen_string_literal: true

# Log model.
class Log < Sequel::Model

  def to_s
    msg =  timestamp.strftime("[%Y-%m-%d %H:%M:%S %z] ")
    msg << status.ljust(7)
    msg << " (#{(list + ',').ljust(10)} #{action})"
    msg << " #{exception}"  if exception

    msg
  end
end
