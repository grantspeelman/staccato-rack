require 'logger'
require 'rack/request'
require 'staccato'

require 'staccato/rack/version'
require 'staccato/rack/page_view'


module Staccato
  module Rack
    # Null Logger class
    class ToNullLogger < Logger
      def initialize(*_args)
      end

      def add(*_args, &_block)
      end
    end

    # middleware
    class Middleware
      # page view wrapper

      attr_accessor :last_hit

      def initialize(app, tracking_id, options = {})
        @app = app
        @tracking_id = tracking_id
        @default_tracker = Staccato.tracker(tracking_id)
        @logger = options[:logger] || ToNullLogger.new
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
