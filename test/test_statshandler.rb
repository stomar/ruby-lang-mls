# frozen_string_literal: true

require_relative "helper"


describe MLS::StatsHandler do

  before do
    setup_database
    @stats = MLS::StatsHandler.new
  end

  after do
    teardown_database
  end

  it "can increment an existing entry (1)" do
    @stats.increment("ruby-talk", "subscribe", timestamp: Time.utc(2000, 1, 2, 12, 0, 10))

    _(@stats.entries.last).must_match "2000-01-02,5"
  end

  it "can increment an existing entry (2)" do
    @stats.increment("ruby-core", "unsubscribe", timestamp: Time.utc(2000, 1, 2, 12, 0, 10))

    _(@stats.entries.last).must_match "2000-01-02,4,0,0,1"
  end

  it "can increment a non-existing entry" do
    @stats.increment("ruby-talk", "subscribe", timestamp: Time.utc(2010, 1, 1))

    _(@stats.entries.last).must_match "2010-01-01,1"
  end

  it "can increment a non-existing entry for today" do
    now = Time.utc(2010, 1, 1)
    Time.stub(:now, now) do
      @stats.increment("ruby-talk", "unsubscribe")
    end

    _(@stats.entries.last).must_match "2010-01-01,0,1"
  end

  it "can return all entries in correct order" do
    _(@stats.entries.size).must_equal 3
    _(@stats.entries[0]).must_match "date,talk_subsc"
    _(@stats.entries[1]).must_match "2000-01-01,7"
    _(@stats.entries[2]).must_match "2000-01-02,4"
  end
end
