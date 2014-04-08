require 'minitest/autorun'
require 'minitest/spec'
require 'lib/mllogger'


describe MLLogger do

  before do
    @db_file = File.expand_path(File.dirname(__FILE__) + '/test.db')
    @mllogger = MLLogger.new(:database_url => "sqlite3://#{@db_file}")

    @time1 = Time.utc(2013, 1, 2, 3, 4, 5)
    @time2 = Time.utc(2013, 1, 2, 3, 4, 6)
    @info1 = { :status => 'Success', :list => 'ruby-talk', :action => 'test' }
    @info2 = { :status => 'Success', :list => 'ruby-core', :action => 'subscribe' }
  end

  it 'can log an entry' do
    capture_io do
      @mllogger.log(@info1)
    end

    @mllogger.entries.split("\n").last.must_match /Success \(ruby-talk, test\)/
  end

  it 'can return all entries in correct order' do
    capture_io do
      Time.stub(:now, @time2) do
        @mllogger.log(@info2)
      end
      Time.stub(:now, @time1) do
        45.times { @mllogger.log(@info1) }
      end
    end
    @mllogger.entries.split("\n").size.must_equal 46
    @mllogger.entries.split("\n").last.must_match /2013-01-02 03:04:06/
  end

  it 'can return recent entries in correct order' do
    capture_io do
      Time.stub(:now, @time2) do
        @mllogger.log(@info2)
      end
      Time.stub(:now, @time1) do
        42.times { @mllogger.log(@info1) }
      end
    end
    @mllogger.recent_entries.split("\n").size.must_equal 40
    @mllogger.recent_entries.split("\n").last.must_match /2013-01-02 03:04:06/
  end

  after do
    DataObjects::Pooling.pools.each {|pool| pool.dispose }  # close connection
    File.delete(@db_file)  if File.exist?(@db_file)
  end
end
