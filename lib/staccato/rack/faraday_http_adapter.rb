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

      def post(data)
        Thread.new(data) do |body_data|
          @conn.post do |req|
            req.url '/collect'
            req.options.timeout = 1           # open/read timeout in seconds
            req.body = body_data
          end
        end
      end
    end
  end
end
