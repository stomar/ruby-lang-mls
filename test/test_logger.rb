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

    _(Log.last.to_s).must_match "Success (ruby-talk, test success)"
  end

  it "can log an entry (invalid)" do
    capture_io do
      @logger.log_invalid("ruby-talk", "test invalid")
    end

    _(Log.last.to_s).must_match "Invalid (ruby-talk, test invalid)"
  end

  it "can log an entry (error)" do
    capture_io do
      @logger.log_error("ruby-talk", "test error", RuntimeError.new("message"))
    end

    _(Log.last.to_s).must_match %r{Error +\(ruby-talk, test error\) RuntimeError\z}
  end
end
