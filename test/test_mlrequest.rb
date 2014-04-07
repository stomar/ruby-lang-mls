require 'minitest/autorun'
require 'minitest/spec'
require 'lib/mlrequest'


describe MLRequest do

  it 'can validate a valid request' do
    @request = MLRequest.new({
                 :list   => 'ruby-talk',
                 :email  => 'john.doe@test.org',
                 :action => 'subscribe'
               })
    @request.valid?.must_equal true
  end

  it 'can validate an invalid request' do
    @request = MLRequest.new({
                 :list   => 'ruby-talk',
                 :action => 'subscribe'
               })
    @request.valid?.must_equal false
  end
end
