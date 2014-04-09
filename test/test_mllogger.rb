require 'minitest/autorun'
require 'minitest/spec'
require 'lib/mllogger'


describe MLLogger do

  before do
    @db_file = File.expand_path(File.dirname(__FILE__) + '/test.db')
    @mllogger = MLLogger.new(:database_url => "sqlite3://#{@db_file}")

    @time1 = Time.utc(2013, 1, 2, 3, 4, 5)
    @time2 = Time.utc(2013, 1, 2, 3, 4, 6)
    @list1, @action1 = 'ruby-talk', 'test'
    @list2, @action2 = 'ruby-core', 'subscribe'
  end

  it 'can log an entry (success)' do
    capture_io do
      @mllogger.log(@list1, @action1)
    end

    @mllogger.entries.last.must_match /Success \(ruby-talk, test\)/
  end

  it 'can log an entry (invalid)' do
    capture_io do
      @mllogger.log_invalid(@list1, @action1)
    end

    @mllogger.entries.last.must_match /Invalid \(ruby-talk, test\)/
  end

  it 'can log an entry (error)' do
    capture_io do
      @mllogger.log_error(@list1, @action1, RuntimeError.new("message"))
    end

    @mllogger.entries.last.must_match /Error +\(ruby-talk, test\) RuntimeError\z/
  end

  it 'can return all entries in correct order' do
    capture_io do
      Time.stub(:now, @time2) do
        @mllogger.log(@list2, @action2)
      end
      Time.stub(:now, @time1) do
        45.times { @mllogger.log(@list1, @action1) }
      end
    end
    @mllogger.entries.size.must_equal 46
    @mllogger.entries.last.must_match /2013-01-02 03:04:06/
  end

  it 'can return recent entries in correct order' do
    capture_io do
      Time.stub(:now, @time2) do
        @mllogger.log(@list2, @action2)
      end
      Time.stub(:now, @time1) do
        42.times { @mllogger.log(@list1, @action2) }
      end
    end
    @mllogger.recent_entries.size.must_equal 40
    @mllogger.recent_entries.last.must_match /2013-01-02 03:04:06/
  end

  after do
    DataObjects::Pooling.pools.each {|pool| pool.dispose }  # close connection
    File.delete(@db_file)  if File.exist?(@db_file)
  end
end
