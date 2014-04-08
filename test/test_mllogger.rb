require 'minitest/autorun'
require 'minitest/spec'
require 'lib/mllogger'


describe MLLogger do

  before do
    @db_file = File.expand_path(File.dirname(__FILE__) + '/test.db')
    @mllogger = MLLogger.new(:database_url => "sqlite3://#{@db_file}")

    @time = Time.utc(2013, 1, 2, 3, 4, 5)
    @info = { :status => 'Success', :list => 'ruby-talk', :action => 'test' }
  end

  it 'can log an entry' do
    time = Time.utc(2013, 2, 2, 3, 4, 5)
    info = { :status => 'Success', :list => 'ruby-core', :action => 'subscribe' }

    capture_io do
      Time.stub(:now, @time) { @mllogger.log(@info) }
      Time.stub(:now, time)  { @mllogger.log(info)  }
    end

    last = @mllogger.entries.split("\n").last
    last.must_equal "[2013-02-02 03:04:05 +0000] Success (ruby-core, subscribe)"
  end

  it 'can return all entries' do
    capture_io do
      @mllogger.log(@info)
      @mllogger.log(@info)
      @mllogger.log(@info)
    end

    @mllogger.entries.split("\n").size.must_equal 3
  end

  after do
    DataObjects::Pooling.pools.each {|pool| pool.dispose }  # close connection
    File.delete(@db_file)  if File.exist?(@db_file)
  end
end
