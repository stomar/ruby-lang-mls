# frozen_string_literal: true

require_relative "models/log"
require_relative "models/dailystats"

model_classes = [Log, DailyStats]
model_classes.each(&:finalize_associations)
model_classes.each(&:freeze)
DB.freeze
