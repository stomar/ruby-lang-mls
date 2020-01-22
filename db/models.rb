# frozen_string_literal: true

if DB && DB.tables.include?(:logs) && DB.tables.include?(:daily_stats)
  require_relative "../models/log"
  require_relative "../models/dailystats"

  model_classes = [Log, DailyStats]
  model_classes.each(&:finalize_associations)
  model_classes.each(&:freeze)
  DB.freeze
else
  warn "Missing database tables - you might need to run `rake db:setup'."
end
