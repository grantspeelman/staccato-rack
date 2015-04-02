require 'staccato/rack/version'
require 'rack/request'

module Staccato
  module Rack
    # middleware
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        # req = ::Rack::Request.new(env)
        # First, call `@app`
        status, headers, body  = @app.call(env)

        # return result
        [status, headers, body]
      end
    end
  end
end
