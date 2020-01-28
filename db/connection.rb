# frozen_string_literal: true

require "sequel"

DATABASE_URL = ENV["DATABASE_URL"] || "sqlite://#{Dir.pwd}/db/development.db"

begin
  DB = Sequel.connect(DATABASE_URL)
rescue StandardError, LoadError => e
  warn "Error initializing database: #{e.class}: #{e}"
  DB = false
end
