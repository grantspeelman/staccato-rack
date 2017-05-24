require File.expand_path '../../../minitest_helper.rb', __FILE__
require 'rr'

# Null Logger class
class DummyLogger
  def info(*_args, &_block); end
end

describe Staccato::Rack::PageView do
  let(:subject) do
    pv = Staccato::Rack::PageView.new
    pv.logger = DummyLogger.new
    pv
  end
  let(:request) do
    r = ::Rack::Request.new({})
    stub(r).env { {} }
    stub(r).fullpath { '/' }
    r
  end
  let(:tracker) { Staccato.tracker(nil) }

  describe '#add_custom_metric' do
    it 'tracks the page when 200' do
      subject.add_custom_metric(2, 20)
      hit = subject.track!(tracker, nil, request)
      hit.params.must_equal('v' => 1, 't' => 'pageview', 'dp' => '/', 'cm2' => 20)
    end

    it 'tracks the page when 200 setting client_id' do
      subject.client_id = 'hello-world'
      hit = subject.track!(tracker, nil, request)
      hit.params.must_equal('v' => 1, 't' => 'pageview', 'dp' => '/')
    end
  end
end
