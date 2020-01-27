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
