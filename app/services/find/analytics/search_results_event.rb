# frozen_string_literal: true

module Find
  module Analytics
    class SearchResultsEvent < ApplicationEvent
      attr_accessor :search_params, :total, :page, :results
      attr_writer :track_params

      def event_name
        :search_results
      end

      def event_data
        {
          total:,
          page:,
          search_params:,
          track_params:,
          visible_courses:
        }
      end

      private

      def visible_courses
        Array(@results).map do |result|
          {
            code: result.course_code,
            provider_code: result.provider_code
          }
        end
      end

      DEFAULT_TRACK_PARAMS = { utm_source: 'results', utm_medium: 'no_referer' }.freeze
      private_constant :DEFAULT_TRACK_PARAMS

      def track_params
        return DEFAULT_TRACK_PARAMS if request.referer.blank?

        if course_view_referer?
          { utm_source: 'course', utm_medium: 'course_view' }.merge(course_view_referer)
        else
          @track_params
        end
      end

      def course_view_referer?
        course_view_referer.present?
      end

      def course_view_referer
        uri = URI.parse(request.referer)
        match = uri.path.match(
          %r{\A/course/(?<provider_code>[^/]+)/(?<code>[^/]+)\z}
        )

        { provider_code: match[:provider_code], code: match[:code] } if match.present?
      rescue StandardError
        nil
      end
    end
  end
end
