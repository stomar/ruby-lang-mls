# frozen_string_literal: true

# Log model.
class Log < Sequel::Model

  dataset_module do
    order :by_date, :timestamp
    exclude :errors, status: "Success"

    def recent_by_date(limit = 40)
      ids = reverse(:timestamp).limit(limit).select(:id)

      where(id: ids).by_date
    end
  end

  def to_s
    msg =  timestamp.strftime("[%Y-%m-%d %H:%M:%S %z] ")
    msg << status.ljust(7)
    msg << " (#{"#{list},".ljust(10)} #{action})"
    msg << " #{exception}"  if exception

    msg
  end
end
