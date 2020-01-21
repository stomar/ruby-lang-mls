# frozen_string_literal: true

if DB && DB.tables.include?(:logs) && DB.tables.include?(:daily_stats)
  require_relative "mls/models"
else
  warn "Missing database tables - you might need to run `rake db:setup'."
end

require_relative "mls/request"
require_relative "mls/mailer"
require_relative "mls/logger"
require_relative "mls/statshandler"
