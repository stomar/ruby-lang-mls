# frozen_string_literal: true

# Log model.
class Log < Sequel::Model

  dataset_module do
    order :by_date, :timestamp
    exclude :errors, status: "Success"

    def recent_by_date(limit = 40)
      Log.reverse(:timestamp).limit(limit).all.reverse
    end
  end

  def to_s
    msg =  timestamp.strftime("[%Y-%m-%d %H:%M:%S %z] ")
    msg << status.ljust(7)
    msg << " (#{(list + ',').ljust(10)} #{action})"
    msg << " #{exception}"  if exception

    msg
  end
end
