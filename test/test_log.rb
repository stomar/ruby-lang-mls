# frozen_string_literal: true

require_relative "helper"


describe Log do

  before do
    setup_database
  end

  after do
    teardown_database
  end

  it "can be created" do
    create_log
  end

  it "can return all entries in correct order" do
    create_log(timestamp: Time.utc(2000, 1, 1, 12, 0, 2))
    create_log(timestamp: Time.utc(2000, 1, 2, 12, 0, 4), list: "last")
    create_log(timestamp: Time.utc(2000, 1, 1, 12, 0, 1), list: "first")
    create_log(timestamp: Time.utc(2000, 1, 2, 12, 0, 3))

    _(Log.count).must_equal 4
    _(Log.by_date.first.to_s).must_match "first"
    _(Log.by_date.last.to_s).must_match "last"
  end

  it "can return recent entries in correct order" do
    latest  = Time.utc(2020, 1, 1)
    earlier = Time.utc(2019, 1, 1)

    create_log(timestamp: earlier)
    create_log(timestamp: latest, list: "latest")
    42.times { create_log(timestamp: earlier) }

    _(Log.recent_by_date.count).must_equal 40
    _(Log.recent_by_date.last.to_s).must_match "latest"
  end

  it "can return all errors in correct order" do
    create_log(timestamp: Time.utc(2000, 1, 1), status: "Success")
    create_log(timestamp: Time.utc(2000, 1, 5), status: "Invalid", list: "last")
    create_log(timestamp: Time.utc(2000, 1, 3), status: "Error")
    create_log(timestamp: Time.utc(2000, 1, 4), status: "Success")
    create_log(timestamp: Time.utc(2000, 1, 2), status: "Error", list: "first")
    create_log(timestamp: Time.utc(2000, 1, 6), status: "Success")

    _(Log.errors.count).must_equal 3
    _(Log.errors.by_date.first.to_s).must_match "first"
    _(Log.errors.by_date.last.to_s).must_match "last"
  end
end
