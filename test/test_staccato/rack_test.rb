require File.expand_path '../../minitest_helper.rb', __FILE__

require 'rack/test'

# test rack class
class TestRack
  def call(_env)
    [200, { 'Content-Type' => 'text/html' }, ['Text Here']]
  end
end

describe 'TestRack' do
  include Rack::Test::Methods
  def header_location
    last_response.headers['Location']
  end

  def app
    Staccato::Rack::Middleware.new(TestRack.new)
  end

  it 'does not redirect on home page' do
    get '/'
    last_response.status.must_equal 200
    last_response.body.must_equal 'Text Here'
  end
end
