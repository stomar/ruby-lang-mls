# frozen_string_literal: true

require_relative "connection"

unless DB && DB.tables.sort == %i[daily_stats logs]
  warn "Required database tables missing. You might need to run `rake db:setup'."
  exit 1
end

require_relative "../models/log"
require_relative "../models/dailystats"

model_classes = [Log, DailyStats]
model_classes.each(&:finalize_associations)
model_classes.each(&:freeze)
DB.freeze
