require "rack/ssl"
require "./app"

use Rack::SSL  if ENV["RACK_ENV"] == "production"

run App
