require 'staccato/rack/version'
require 'staccato'
require 'rack/request'
require 'ostruct'

module Staccato
  module Rack
    # middleware
    class Middleware
      # page view wrapper
      class PageView < OpenStruct
        def initialize
          super
          @custom_metrics = []
          @custom_dimensions = []
        end

        def add_custom_metric(position, value)
          @custom_metrics << [position, value]
        end

        def add_custom_dimension(position, value)
          @custom_dimensions << [position, value]
        end

        def track!(default_tracker, tracking_id, request)
          page_view_params = marshal_dump
          if page_view_params[:client_id]
            tracker = Staccato.tracker(tracking_id, page_view_params[:client_id])
          else
            tracker = default_tracker
          end
          track_hit(tracker, page_view_params, request)
        end

        private

        def track_hit(tracker, page_view_params, request)
          hit = Staccato::Pageview.new(tracker, page_view_params.merge(path: request.fullpath,
                                                                       hostname: request.host,
                                                                       user_agent: request.env['HTTP_USER_AGENT'],
                                                                       user_ip: request.ip))
          add_custom_to_hit(hit)
          hit.track!
          hit
        end

        def add_custom_to_hit(hit)
          @custom_metrics.each do |p, v|
            hit.add_custom_metric(p, v)
          end
          @custom_dimensions.each do |p, v|
            hit.add_custom_dimension(p, v)
          end
        end
      end

      attr_accessor :last_hit

      def initialize(app, tracking_id)
        @app = app
        @tracking_id = tracking_id
        @default_tracker = Staccato.tracker(tracking_id)
      end

      def call(env)
        env['staccato.pageview'] = PageView.new

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
