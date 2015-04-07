require File.expand_path '../../minitest_helper.rb', __FILE__

require 'rack/test'

# test rack class
class TestRack
  attr_accessor :status, :headers, :body, :client_id, :pageview

  def initialize
    @status = 200
    @headers = { 'Content-Type' => 'text/html' }
    @body = ['Text Here']
    @env_block = nil
  end

  def env(&block)
    @env_block = block
  end

  def call(env)
    @env_block.call(env) if @env_block
    @pageview = env['staccato.pageview']
    [@status, @headers, @body]
  end
end

describe 'TestRack' do
  include Rack::Test::Methods

  def app
    @middleware
  end

  before :each do
    @test_rack = TestRack.new
    @middleware = Staccato::Rack::Middleware.new(@test_rack, nil)
  end

  it 'tracks the page when 200' do
    @test_rack.status = 200
    get '/'
    @test_rack.pageview.params.must_equal('v' => 1, 't' => 'pageview', 'dh' => 'example.org',
                                          'dp' => '/', 'uip' => '127.0.0.1')
  end

  it 'tracks the page when 299' do
    @test_rack.status = 299
    get '/'
    @test_rack.pageview.params.must_equal('v' => 1, 't' => 'pageview', 'dh' => 'example.org',
                                          'dp' => '/', 'uip' => '127.0.0.1')
  end

  it 'wont track page if status 302' do
    Staccato::Pageview.stub :new, 'Do not touch me' do
      @test_rack.status = 302
      get '/'
    end
  end

  it 'can set user_id' do
    @test_rack.env do |env|
      env['staccato.pageview'].options.user_id = '123'
    end
    get '/'
    @test_rack.pageview.params.must_equal('v' => 1, 't' => 'pageview', 'dh' => 'example.org',
                                          'dp' => '/', 'uid' => '123', 'uip' => '127.0.0.1')
  end

  it 'can add_custom_dimension' do
    @test_rack.env do |env|
      env['staccato.pageview'].add_custom_dimension(1, 'Male')
    end
    get '/'
    @test_rack.pageview.params.must_equal('v' => 1, 't' => 'pageview', 'dh' => 'example.org',
                                          'dp' => '/', 'uip' => '127.0.0.1', 'cd1' => 'Male')
  end

  it 'can add_custom_metric' do
    @test_rack.env do |env|
      env['staccato.pageview'].add_custom_metric(2, 20)
    end
    get '/'
    @test_rack.pageview.params.must_equal('v' => 1, 't' => 'pageview', 'dh' => 'example.org',
                                          'dp' => '/', 'uip' => '127.0.0.1', 'cm2' => 20)
  end
end
