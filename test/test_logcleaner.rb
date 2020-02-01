# frozen_string_literal: true

require_relative "helper"
require_relative "../lib/mls/logcleaner"


describe MLS::LogCleaner do

  before do
    setup_database
    @logcleaner = MLS::LogCleaner.new
  end

  after do
    teardown_database
  end

  it "can clean up logs" do
    create_log(status: "Success")
    create_log(status: "Invalid")
    create_log(status: "Error")
    create_log(status: "Success")
    create_log(status: "Error")

    _(Log.all.size).must_equal 5
    _(Log.all.map(&:to_s).grep(/Success/)).wont_be_empty

    capture_io do
      @logcleaner.cleanup_all
    end

    _(Log.all.size).must_equal 3
    _(Log.all.map(&:to_s).grep(/Success/)).must_be_empty
  end
end
