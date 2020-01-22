# frozen_string_literal: true

require "minitest/autorun"

ENV["DATABASE_URL"] = "sqlite:/"

require_relative "../app"


def setup_database
  load File.expand_path("fixtures.rb", __dir__)
end

def teardown_database
  Log.dataset.destroy  if DB
  DailyStats.dataset.destroy  if DB
end

def silence_warnings
  original_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = original_verbose
end
