# frozen_string_literal: true

require_relative "helper"


describe MLS::Logger do

  before do
    setup_database
    @logger = MLS::Logger.new
  end

  after do
    teardown_database
  end

  it "can log an entry (success)" do
    capture_io do
      @logger.log("ruby-talk", "test success")
    end

    @logger.entries.last.must_match /Success \(ruby-talk, test success\)/
  end

  it "can log an entry (invalid)" do
    capture_io do
      @logger.log_invalid("ruby-talk", "test invalid")
    end

    @logger.entries.last.must_match /Invalid \(ruby-talk, test invalid\)/
  end

  it "can log an entry (error)" do
    capture_io do
      @logger.log_error("ruby-talk", "test error", RuntimeError.new("message"))
    end

    @logger.entries.last.must_match /Error +\(ruby-talk, test error\) RuntimeError\z/
  end

  it "can return all entries in correct order" do
    @logger.entries.size.must_equal 6
    @logger.entries.first.must_match /2000-01-02 12:00:01.*test_first/
    @logger.entries.last.must_match  /2000-01-02 12:00:06.*test_last/
  end

  it "can return recent entries in correct order" do
    some_time_ago = Time.utc(2010, 1, 1)
    capture_io do
      @logger.log("ruby-talk", "latest")
      Time.stub(:now, some_time_ago) do
        42.times { @logger.log("ruby-talk", "older") }
      end
    end

    @logger.recent_entries.size.must_equal 40
    @logger.recent_entries.last.must_match /ruby-talk, latest/
  end

  it "can return all errors in correct order" do
    @logger.errors.size.must_equal 2
    @logger.errors.first.must_match /2000-01-02 12:00:03.*test_error/
    @logger.errors.last.must_match  /2000-01-02 12:00:04.*test_invalid/
  end
end
