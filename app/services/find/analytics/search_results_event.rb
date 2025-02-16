# frozen_string_literal: true

module Find
  module Analytics
    class SearchResultsEvent < ApplicationEvent
      attr_accessor :search_params, :track_params, :total, :page, :results

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
    end
  end
end
