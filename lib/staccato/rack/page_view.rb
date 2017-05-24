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
        tracker = if page_view_params[:client_id]
                    Staccato.tracker(tracking_id, page_view_params[:client_id]) do |c|
                      c.adapter = FaradayAsyncHttpAdaper.new(logger) unless tracking_id.nil?
                    end
                  else
                    default_tracker
                  end
        track_hit(tracker, page_view_params, request)
      end

      private

      def track_hit(tracker, page_view_params, request)
        hit = Staccato::Pageview.new(tracker, { path: request.fullpath,
                                                user_agent: request.env['HTTP_USER_AGENT'],
                                                user_ip: request.ip }.merge(page_view_params))
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
  end
end
