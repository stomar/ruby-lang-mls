# frozen_string_literal: true

require "minitest/autorun"

ENV["DATABASE_URL"] = "sqlite:/"

require_relative "../db/schema"
require_relative "../db/models"
require_relative "../app"


def setup_database
  load File.expand_path("fixtures.rb", __dir__)
end

def teardown_database
  DB.tables.each {|table| DB[table].delete }
end

def silence_warnings
  original_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = original_verbose
end

def create_log(attributes = {})
  defaults = {
    timestamp: Time.now.utc,
    list: "default",
    action: "default",
    status: "default"
  }

  DB[:logs].insert(defaults.merge(attributes))
end

def create_dailystats(attributes = {})
  defaults = {
    date: Time.now.utc.to_date
  }

  DB[:daily_stats].insert(defaults.merge(attributes))
end
