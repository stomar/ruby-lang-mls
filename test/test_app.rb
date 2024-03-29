# frozen_string_literal: true

require_relative "helper"

require "rack/test"

def app
  App
end

class SampleRequest

  def initialize
    @fields = {
      list: "ruby-talk",
      email: "john.doe@test.org",
      action: "subscribe"
    }
  end

  def to_s
    parts = @fields.sort.map {|k, v| "#{k}=#{Rack::Utils.escape(v)}" }

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
    expected = "action=subscribe&email=john.doe%40test.org&list=ruby-talk"
    _(request.to_s).must_equal expected
  end

  it "can return a request with a replaced field" do
    request = SampleRequest.new.replace(:action, "unsubscribe")
    expected = "action=unsubscribe&email=john.doe%40test.org&list=ruby-talk"
    _(request.to_s).must_equal expected
  end

  it "can return a request without a specified field" do
    request = SampleRequest.new.without(:action)
    expected = "email=john.doe%40test.org&list=ruby-talk"
    _(request.to_s).must_equal expected
  end
end


describe "application environment" do

  it "uses UTC as local time zone" do
    _(Time.now.strftime("%z")).must_equal "+0000"
  end
end


describe "request validation" do
  include Rack::Test::Methods

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
    _(last_response.body).must_match "Invalid"
  end

  it "fails for whitespace-only email" do
    capture_io do
      post "/submit?#{@request.replace(:email, '    ')}"
    end
    _(last_response.body).must_match "Invalid"
  end

  it "fails for nonexistent mailing list" do
    capture_io do
      post "/submit?#{@request.replace(:list, 'ruby-test')}"
    end
    _(last_response.body).must_match "Invalid"
  end

  it "fails for missing mailing list" do
    capture_io do
      post "/submit?#{@request.without(:list)}"
    end
    _(last_response.body).must_match "Invalid"
  end

  it "fails for invalid action" do
    capture_io do
      post "/submit?#{@request.replace(:action, 'login')}"
    end
    _(last_response.body).must_match "Invalid"
  end

  it "fails for missing action" do
    capture_io do
      post "/submit?#{@request.without(:action)}"
    end
    _(last_response.body).must_match "Invalid"
  end

  it "does not mind additional fields" do
    # stub out Pony.mail to prevent actual mail request
    Pony.stub(:mail, "no-op") do
      capture_io do
        post "/submit?#{@request.add(:first_name, 'John')}"
      end
    end
    _(last_response.body).must_match "<h1>Confirmation</h1>"
  end
end


describe "email sending" do
  include Rack::Test::Methods

  before do
    setup_database
    @request = SampleRequest.new
  end

  after do
    teardown_database
  end

  it "sends an email for a vaild request" do
    expected_arg = {
      to: "ruby-talk-request@ruby-lang.org",
      body: "subscribe address=john.doe@test.org"
    }

    mock = Minitest::Mock.new
    mock.expect(:call, nil, [expected_arg])

    Pony.stub(:mail, mock) do
      capture_io do
        post "/submit?#{@request}"
      end
    end

    mock.verify
    _(last_response.body).must_match "<h1>Confirmation</h1>"
  end

  it "indicates an error for failed send process" do
    # stub that succeeds
    Pony.stub(:mail, ->(_) { "no-op" }) do
      capture_io do
        post "/submit?#{@request}"
      end
    end
    _(last_response.body).must_match "<h1>Confirmation</h1>"

    # stub that errors
    Pony.stub(:mail, ->(_) { raise "mock exception" }) do
      capture_io do
        post "/submit?#{@request}"
      end
    end
    _(last_response.body).must_match "<h1>Error</h1>"
  end
end
