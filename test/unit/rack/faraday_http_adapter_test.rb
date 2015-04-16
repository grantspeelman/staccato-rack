require File.expand_path '../../../minitest_helper.rb', __FILE__

describe Staccato::Rack::FaradayHttpAdaper do
  let(:subject) do
    Staccato::Rack::FaradayHttpAdaper.new
  end

  describe '#post' do
    it 'posts' do
      stub_request(:post, 'https://ssl.google-analytics.com/collect')
        .with(body: { 'this' => 'is a test' },
              headers: { 'Accept' => '*/*',
                         'Content-Type' => 'application/x-www-form-urlencoded',
                         'User-Agent' => 'Faraday v0.9.1' })
        .to_return(status: 200, body: '', headers: {})
      subject.post('this' => 'is a test').join
    end
  end
end