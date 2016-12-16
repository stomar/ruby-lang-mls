require "minitest/autorun"

DB_FILE = File.expand_path(File.dirname(__FILE__) + '/test.db')
ENV["DATABASE_URL"] = "sqlite:///#{DB_FILE}"


def setup_database
  DataMapper.auto_upgrade!
end

def teardown_database
  Log.destroy
  DailyStats.destroy

  DataObjects::Pooling.pools.each {|pool| pool.dispose }  # close connection
  File.delete(DB_FILE)  if File.exist?(DB_FILE)
end
