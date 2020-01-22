# frozen_string_literal: true

require "sequel"

DATABASE_URL = ENV["DATABASE_URL"] || "sqlite://#{Dir.pwd}/db/development.db"

begin
  DB = Sequel.connect(DATABASE_URL)

  # create tables for in-memory database
  if ENV["DATABASE_URL"] == "sqlite:/"
    load File.expand_path("schema.rb", __dir__)
  end
rescue StandardError, LoadError => e
  warn "Error initializing database: #{e.class}: #{e}"
  DB = false
end
