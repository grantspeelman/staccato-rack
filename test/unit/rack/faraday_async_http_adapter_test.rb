require File.expand_path '../../../minitest_helper.rb', __FILE__

describe Staccato::Rack::FaradayAsyncHttpAdaper do
  let(:subject) do
    Staccato::Rack::FaradayAsyncHttpAdaper.new
  end

  describe '#post' do
    it 'posts' do
      stub_request(:post, 'https://ssl.google-analytics.com/collect')
        .with(body: { 'this' => 'is a test' },
              headers: { 'Accept' => '*/*', 'Content-Type' => 'application/x-www-form-urlencoded' })
        .to_return(status: 200, body: '', headers: {})
      subject.post('this' => 'is a test').join
    end
  end
end
