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
    create_dailystats
  end

  it "can return all entries in correct order" do
    create_dailystats(date: Date.new(2000, 1, 2), talk_subsc: 4)
    create_dailystats(date: Date.new(2000, 1, 1), talk_subsc: 7)

    _(DailyStats.count).must_equal 2
    _(DailyStats.by_date.first.to_s).must_match "2000-01-01,7"
    _(DailyStats.by_date.last.to_s).must_match "2000-01-02,4"
  end
end
