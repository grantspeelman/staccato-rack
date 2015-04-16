require File.expand_path '../../minitest_helper.rb', __FILE__

require 'rack/test'

# test rack class
class TestRack
  attr_accessor :status, :headers, :body, :client_id

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
    [@status, @headers, @body]
  end
end

describe 'Integration' do
  include Rack::Test::Methods

  def app
    @middleware
  end

  def default_params
    { 'v' => 1, 'tid' => 'UA-TEST', 'cid' => @middleware.last_hit.params['cid'],
      't' => 'pageview', 'uip' => '127.0.0.1' }
  end

  before :each do
    @test_rack = TestRack.new
    @middleware = Staccato::Rack::Middleware.new(@test_rack, 'UA-TEST')
  end

  it 'tracks the page when 200' do
    @test_rack.status = 200
    get '/'
    @middleware.last_hit.params.must_equal(default_params.merge('dp' => '/'))
  end

  it 'tracks the page when 299' do
    @test_rack.status = 299
    get '/'
    @middleware.last_hit.params.must_equal(default_params.merge('dp' => '/'))
  end

  it 'tracks the remote ip' do
    @test_rack.status = 299
    get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'
    @middleware.last_hit.params.must_equal(default_params.merge('dp' => '/', 'uip' => '1.2.3.4'))
  end

  it 'wont track page if status 302' do
    Staccato::Pageview.stub :new, 'Do not touch me' do
      @test_rack.status = 302
      get '/'
      @middleware.last_hit.must_be_nil
    end
  end

  it 'can set client_id' do
    @test_rack.env do |env|
      env['staccato.pageview'].client_id = '123'
    end
    get '/'
    @middleware.last_hit.tracker.client_id.must_equal('123')
  end

  it 'can set user_id' do
    @test_rack.env do |env|
      env['staccato.pageview'].user_id = '123'
    end
    get '/'
    @middleware.last_hit.params.must_equal(default_params.merge('dp' => '/', 'uid' => '123'))
  end

  it 'can add_custom_dimension' do
    @test_rack.env do |env|
      env['staccato.pageview'].add_custom_dimension(1, 'Male')
    end
    get '/'
    @middleware.last_hit.params.must_equal(default_params.merge('dp' => '/', 'cd1' => 'Male'))
  end

  it 'can add_custom_metric' do
    @test_rack.env do |env|
      env['staccato.pageview'].add_custom_metric(2, 20)
    end
    get '/'
    @middleware.last_hit.params.must_equal(default_params.merge('dp' => '/', 'cm2' => 20))
  end

  it 'can set a custom logger' do
    string_io = StringIO.new
    @middleware = Staccato::Rack::Middleware.new(@test_rack, 'UA-TEST', logger: Logger.new(string_io))
    get '/'
    string_io.string.wont_equal ''
  end

  it 'can set a custom logger and works with no UA code' do
    string_io = StringIO.new
    @middleware = Staccato::Rack::Middleware.new(@test_rack, nil, logger: Logger.new(string_io))
    get '/'
    string_io.string.wont_equal ''
  end
end
