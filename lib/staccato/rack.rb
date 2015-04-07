require 'staccato/rack/version'
require 'staccato'
require 'rack/request'

module Staccato
  module Rack
    # middleware
    class Middleware
      attr_accessor :last_hit

      def initialize(app, tracking_id)
        @app = app
        @tracker = Staccato.tracker(tracking_id)
      end

      def call(env)
        # First, call `@app`
        load_staccato_into_env(env)

        # @last_hit = nil
        status, headers, body  = @app.call(env)

        env['staccato.tracker'].track(env['staccato.pageview'].params) if (200..299).include?(status.to_i)

        # return result
        [status, headers, body]
      end

      private

      def load_staccato_into_env(env)
        request = ::Rack::Request.new(env)
        env['staccato.tracker'] = @tracker
        env['staccato.pageview'] = Staccato::Pageview.new(@tracker,
                                                          path: request.fullpath,
                                                          hostname: request.host,
                                                          user_agent: request.env['HTTP_USER_AGENT'],
                                                          user_ip: request.ip)
      end
    end
  end
end
