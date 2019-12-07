# frozen_string_literal: true

require_relative "helper"


describe MLS::Request do

  it "returns empty strings for missing or nil request parameters" do
    @request = MLS::Request.new(list: nil)
    _(@request.list).must_equal ""
    _(@request.email).must_equal ""
    _(@request.action).must_equal ""
  end

  it "can validate a valid request" do
    @request = MLS::Request.new(
      list: "ruby-talk",
      email: "john.doe@test.org",
      action: "subscribe"
    )
    _(@request.valid?).must_equal true
  end

  it "can validate an invalid request" do
    @request = MLS::Request.new(
      list: "ruby-talk",
      action: "subscribe"
    )
    _(@request.valid?).must_equal false
  end
end
