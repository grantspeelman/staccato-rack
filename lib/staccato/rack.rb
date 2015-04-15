require 'staccato/rack/version'
require 'staccato'
require 'rack/request'
require 'ostruct'

module Staccato
  module Rack
    # Proxy Class to do page views
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
        hit = Staccato::Pageview.new(tracker, { path: request.fullpath, user_agent: request.env['HTTP_USER_AGENT'],
                                                user_ip: request.ip }.merge(page_view_params))
        add_custom_to_hit(hit)
        begin
          r = hit.track!
          log_response(r, hit)
        rescue => e
          log_error(e, hit)
        end
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

      def log_response(r, hit)
        logger.info "GA Tracking: #{hit.params.inspect} => #{r.response.code if r}"
      end

      def log_error(e, hit)
        logger.error "GA Tracking: #{hit.params.inspect} => #{e.message}"
      end
    end

    # Null Logger clas
    class NullLogger
      def info(*)
      end

      def error(*)
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
        @default_tracker.http_read_timeout = options[:http_read_timeout] if options[:http_read_timeout]
        @default_tracker.http_open_timeout = options[:http_open_timeout] if options[:http_open_timeout]
        @logger = options[:logger] || NullLogger.new
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
