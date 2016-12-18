require "minitest/autorun"

DB_FILE = File.expand_path(File.dirname(__FILE__) + '/test.db')
ENV["DATABASE_URL"] = "sqlite:///#{DB_FILE}"
ENV["NO_LOGS"] = "true"

require_relative "../app"


def setup_database
end

def teardown_database
  Log.destroy  if DB
  DailyStats.destroy  if DB
end


def silence_warnings
  original_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = original_verbose
end
