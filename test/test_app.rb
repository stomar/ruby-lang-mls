# frozen_string_literal: true

require_relative "helper"

require "rack/test"

include Rack::Test::Methods

def app
  App
end


class SampleRequest

  def initialize
    @fields = {
      :list       => "ruby-talk",
      :email      => "john.doe@test.org",
      :action     => "subscribe"
    }
  end

  def to_s
    parts = @fields.sort.map {|k,v| "#{k}=#{Rack::Utils.escape(v)}" }

    parts.join("&")
  end

  def replace(field, value)
    @fields[field] = value

    self
  end

  def add(field, value)
    @fields[field] = value

    self
  end

  def without(field)
    @fields.delete(field)

    self
  end
end


describe SampleRequest do

  it "returns the correct default request" do
    request = SampleRequest.new
    request.to_s.must_equal "action=subscribe&email=john.doe%40test.org&list=ruby-talk"
  end

  it "can return a request with a replaced field" do
    request = SampleRequest.new.replace(:action, "unsubscribe")
    request.to_s.must_equal "action=unsubscribe&email=john.doe%40test.org&list=ruby-talk"
  end

  it "can return a request without a specified field" do
    request = SampleRequest.new.without(:action)
    request.to_s.must_equal "email=john.doe%40test.org&list=ruby-talk"
  end
end


describe "application environment" do

  it "uses UTC as local time zone" do
    Time.now.strftime("%z").must_equal "+0000"
  end
end


describe "request validation" do

  before do
    setup_database
    @request = SampleRequest.new
  end

  after do
    teardown_database
  end

  it "fails for missing email" do
    capture_io do
      post "/submit?#{@request.without(:email)}"
    end
    last_response.body.must_match "Invalid"
  end

  it "fails for whitespace-only email" do
    capture_io do
      post "/submit?#{@request.replace(:email, '    ')}"
    end
    last_response.body.must_match "Invalid"
  end

  it "fails for nonexistent mailing list" do
    capture_io do
      post "/submit?#{@request.replace(:list, 'ruby-test')}"
    end
    last_response.body.must_match "Invalid"
  end

  it "fails for missing mailing list" do
    capture_io do
      post "/submit?#{@request.without(:list)}"
    end
    last_response.body.must_match "Invalid"
  end

  it "fails for invalid action" do
    capture_io do
      post "/submit?#{@request.replace(:action, 'login')}"
    end
    last_response.body.must_match "Invalid"
  end

  it "fails for missing action" do
    capture_io do
      post "/submit?#{@request.without(:action)}"
    end
    last_response.body.must_match "Invalid"
  end

  it "does not mind additional fields" do
    silence_warnings do
      def Pony.mail(options); end
    end

    capture_io do
      post "/submit?#{@request.add(:first_name, 'John')}"
    end
    last_response.body.must_match "<h1>Confirmation</h1>"
  end
end


describe "email sending" do

  before do
    setup_database
    @request = SampleRequest.new
  end

  after do
    teardown_database
  end

  it "sends an email for a vaild request" do
    expected = {
          :to   => "ruby-talk-request@ruby-lang.org",
          :body => "subscribe address=john.doe@test.org"
    }

    silence_warnings do
      Pony = MiniTest::Mock.new
    end

    Pony.expect(:mail, nil, [expected])

    capture_io do
      post "/submit?#{@request}"
    end
    Pony.verify
    last_response.body.must_match "<h1>Confirmation</h1>"
  end

  it "indicates an error for failed send process" do
    silence_warnings do
      def Pony.mail(options)
        raise "fake exception"
      end
    end

    capture_io do
      post "/submit?#{@request}"
    end
    last_response.body.must_match "<h1>Error</h1>"
  end
end
