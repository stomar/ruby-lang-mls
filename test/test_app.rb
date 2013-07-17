require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'

include Rack::Test::Methods

NO_LOGS = true

require 'app'

def app
  App
end


class SampleRequest

  def initialize
    @fields = {
      :list       => 'ruby-talk',
      :first_name => 'John',
      :last_name  => 'Doe',
      :email      => 'john.doe@test.org',
      :action     => 'subscribe'
    }
  end

  def to_s
    parts = @fields.sort.map {|k,v| "#{k}=#{Rack::Utils.escape_path(v)}" }

    parts.join('&')
  end

  def replace(field, value)
    @fields[field] = value

    self
  end

  def without(field)
    @fields.delete(field)

    self
  end
end


describe SampleRequest do

  it 'returns the correct default request' do
    request = SampleRequest.new
    request.to_s.must_equal 'action=subscribe&email=john.doe%40test.org&' <<
                            'first_name=John&last_name=Doe&list=ruby-talk'
  end

  it 'can return a request with a replaced field' do
    request = SampleRequest.new.replace(:first_name, 'Jane')
    request.to_s.must_equal 'action=subscribe&email=john.doe%40test.org&' <<
                            'first_name=Jane&last_name=Doe&list=ruby-talk'
  end

  it 'can return a request without a specified field' do
    request = SampleRequest.new.without(:action)
    request.to_s.must_equal 'email=john.doe%40test.org&first_name=John&' <<
                            'last_name=Doe&list=ruby-talk'
  end
end


describe 'request validation' do

  before do
    @request = SampleRequest.new
  end

  it 'fails for empty first name' do
    post "/submit?#{@request.replace(:first_name, '')}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for whitespace-only first name' do
    post "/submit?#{@request.replace(:first_name, '    ')}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for missing first name' do
    post "/submit?#{@request.without(:first_name)}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for missing last name' do
    post "/submit?#{@request.without(:last_name)}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for missing email' do
    post "/submit?#{@request.without(:email)}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for nonexistent mailing list' do
    post "/submit?#{@request.replace(:list, 'ruby-test')}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for missing mailing list' do
    post "/submit?#{@request.without(:list)}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for invalid action' do
    post "/submit?#{@request.replace(:action, 'login')}"
    last_response.body.must_match 'Invalid'
  end

  it 'fails for missing action' do
    post "/submit?#{@request.without(:action)}"
    last_response.body.must_match 'Invalid'
  end
end


describe 'email sending' do

  before do
    @request = SampleRequest.new
  end

  it 'sends an email for a vaild request' do
    expected = {
          :to   => 'ruby-talk-ctl@ruby-lang.org',
          :from => 'john.doe@test.org',
          :body => 'subscribe John Doe'
    }

    original_verbose, $VERBOSE = $VERBOSE, nil
    Pony = MiniTest::Mock.new
    $VERBOSE = original_verbose

    Pony.expect(:mail, nil, [expected])

    post "/submit?#{@request}"
    Pony.verify
    last_response.body.must_match '<h1>Confirmation</h1>'
  end

  it 'indicates an error for failed send process' do
    original_verbose, $VERBOSE = $VERBOSE, nil
    def Pony.mail(options)
      raise 'exception'
    end
    $VERBOSE = original_verbose

    post "/submit?#{@request}"
    last_response.body.must_match 'Error'
  end
end
