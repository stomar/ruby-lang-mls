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
    entry = { timestamp: Time.utc(2010, 1, 1), status: "Success", list: "ruby-talk", action: "subscribe" }
    Log.create(entry)
  end

  it "can return all entries in correct order" do
    _(Log.count).must_equal 6
    _(Log.by_date.first.to_s).must_match %r{2000-01-02 12:00:01.*test_first}
    _(Log.by_date.last.to_s).must_match  %r{2000-01-02 12:00:06.*test_last}
  end

  it "can return recent entries in correct order" do
    latest = { timestamp: Time.utc(2020, 1, 1), status: "Success", list: "ruby-talk", action: "latest" }
    older  = { timestamp: Time.utc(2010, 1, 1), status: "Success", list: "ruby-talk", action: "older" }

    Log.create(latest)
    42.times { Log.create(older) }

    _(Log.recent_by_date.count).must_equal 40
    _(Log.recent_by_date.last.to_s).must_match "ruby-talk, latest"
  end

  it "can return all errors in correct order" do
    _(Log.errors.count).must_equal 2
    _(Log.errors.by_date.first.to_s).must_match %r{2000-01-02 12:00:03.*test_error}
    _(Log.errors.by_date.last.to_s).must_match  %r{2000-01-02 12:00:04.*test_invalid}
  end
end
