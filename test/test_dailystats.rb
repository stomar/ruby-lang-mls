# frozen_string_literal: true

require_relative "helper"


describe DailyStats do

  before do
    setup_database
  end

  after do
    teardown_database
  end

  it "can be created" do
    entry = { date: Date.new(2000, 1, 1), talk_subsc: 1 }
    DailyStats.create(entry)
  end

  it "can return all entries in correct order" do
    _(DailyStats.count).must_equal 2
    _(DailyStats.by_date.first.to_s).must_match "2000-01-01,7"
    _(DailyStats.by_date.last.to_s).must_match "2000-01-02,4"
  end
end
