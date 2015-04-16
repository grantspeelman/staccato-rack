require 'logger'
require 'rack/request'
require 'staccato'

require 'staccato/rack/version'
require 'staccato/rack/faraday_http_adapter'
require 'staccato/rack/page_view'

module Staccato
  module Rack
    # middleware
    class Middleware
      # page view wrapper

      attr_accessor :last_hit

      def initialize(app, tracking_id, options = {})
        @app = app
        @tracking_id = tracking_id
        @logger = options[:logger]
        @default_tracker = Staccato.tracker(tracking_id) do |c|
          c.adapter = FaradayHttpAdaper.new(@logger)
        end
      end

      def call(env)
        env['staccato.pageview'] = PageView.new.tap { |p| p.logger = @logger }

        @last_hit = nil
        status, headers, body  = @app.call(env)

        if (200..299).include?(status.to_i)
          @last_hit = env['staccato.pageview'].track!(@default_tracker, @tracking_id, ::Rack::Request.new(env))
        end

        # return result
        [status, headers, body]
      end
    end
  end
end
