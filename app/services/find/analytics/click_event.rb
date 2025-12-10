# frozen_string_literal: true

module Find
  module Analytics
    class ClickEvent < ApplicationEvent
      attr_accessor :utm_content, :url

      def event_name
        :track_click
      end

      def namespace
        namespace = request.referer&.scan(/(find|publish)/)&.flatten&.first
        namespace || "unknown"
      end

      def event_data
        {
          data: {
            utm_content:,
            url:,
          },
        }
      end
    end
  end
end
