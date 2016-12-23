require_relative 'helper'


describe MLLogger do

  before do
    setup_database
    @logger = MLLogger.new

    @time1 = Time.utc(2013, 1, 2, 3, 4, 5)
    @time2 = Time.utc(2013, 1, 2, 3, 4, 6)
    @list1, @action1 = 'ruby-talk', 'test'
    @list2, @action2 = 'ruby-core', 'subscribe'
  end

  after do
    teardown_database
  end

  it 'can log an entry (success)' do
    capture_io do
      @logger.log(@list1, @action1)
    end

    @logger.entries.last.must_match /Success \(ruby-talk, test\)/
  end

  it 'can log an entry (invalid)' do
    capture_io do
      @logger.log_invalid(@list1, @action1)
    end

    @logger.entries.last.must_match /Invalid \(ruby-talk, test\)/
  end

  it 'can log an entry (error)' do
    capture_io do
      @logger.log_error(@list1, @action1, RuntimeError.new("message"))
    end

    @logger.entries.last.must_match /Error +\(ruby-talk, test\) RuntimeError\z/
  end

  it 'can return all entries in correct order' do
    capture_io do
      Time.stub(:now, @time2) do
        @logger.log(@list2, @action2)
      end
      Time.stub(:now, @time1) do
        45.times { @logger.log(@list1, @action1) }
      end
    end
    @logger.entries.size.must_equal 46
    @logger.entries.last.must_match /2013-01-02 03:04:06/
  end

  it 'can return recent entries in correct order' do
    capture_io do
      Time.stub(:now, @time2) do
        @logger.log(@list2, @action2)
      end
      Time.stub(:now, @time1) do
        42.times { @logger.log(@list1, @action2) }
      end
    end
    @logger.recent_entries.size.must_equal 40
    @logger.recent_entries.last.must_match /2013-01-02 03:04:06/
  end
end
