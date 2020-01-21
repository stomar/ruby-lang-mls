source "https://rubygems.org"

ruby "2.7.0"

gem "sinatra"

gem "rack", ">= 2.0.8"
gem "rack-ssl"
gem "thin"

gem "sequel"
gem "dm-core"
gem "dm-migrations"

gem "pony"

gem "rake"

group :development do
  gem "dm-sqlite-adapter"
  gem "minitest"
  gem "rack-test"
  gem "sqlite3"
end

group :production do
  gem "pg"
  gem "dm-postgres-adapter"
end
