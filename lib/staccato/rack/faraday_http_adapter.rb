require 'faraday'

module Staccato
  module Rack
    # Proxy Class to do page views
    class FaradayHttpAdaper
      def initialize(logger = nil)
        @logger = logger
        @conn = Faraday.new(url: 'https://ssl.google-analytics.com') do |faraday|
          faraday.request :url_encoded             # form-encode POST params
          faraday.response :logger, @logger if @logger
          faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def post(data, url = '/collect')
        Thread.new(data, url) do
          begin
            execute(data, url)
          rescue => e
            @logger.error "Could not collect #{data.inspect} => #{e.message}"
          end
        end
      end

      private

      def execute(post_data, post_url)
        @conn.post do |req|
          req.url post_url
          req.options.timeout = 2           # open/read timeout in seconds
          req.body = post_data
        end
      end
    end
  end
end
