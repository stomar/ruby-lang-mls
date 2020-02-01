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
      @logger.log("ruby-talk", "test")
    end

    _(Log.last.to_s).must_match "Success (ruby-talk, test)"
  end

  it "can log an entry (invalid)" do
    capture_io do
      @logger.log_invalid("ruby-talk", "test")
    end

    _(Log.last.to_s).must_match "Invalid (ruby-talk, test)"
  end

  it "can log an entry (error)" do
    capture_io do
      @logger.log_error("ruby-talk", "test", RuntimeError.new("message"))
    end

    _(Log.last.to_s).must_match %r{Error +\(ruby-talk, test\) RuntimeError\z}
  end
end
