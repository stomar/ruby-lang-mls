require "rack/ssl"
require "./app"

if ENV["RACK_ENV"] == "production"
  use Rack::SSL
end

run App
