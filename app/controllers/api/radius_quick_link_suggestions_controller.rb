module API
  class RadiusQuickLinkSuggestionsController < ApplicationController
    MAX_RADIUS = Courses::SearchForm::RADIUS_VALUES.max
    MAX_COURSES_COUNT = 100

    def index
      render json: no_results_quick_links
    end

  private

    def no_results_quick_links
      Array.wrap(bucket_counts_from_largest_search_radius.slice_after { it[:count].to_i >= MAX_COURSES_COUNT }.first).map do
        {
          text: t(".radius_in_miles", count: it[:radius], course_count: course_count_translation(count: it[:count])),
          url: find_results_path(**request.query_parameters, radius: it[:radius]),
        }
      end
    end

    def bucket_counts_from_largest_search_radius
      radius_links_query = Courses::Query.call(params: params.merge(radius: MAX_RADIUS)).limit(MAX_COURSES_COUNT + 1)

      Courses::SearchForm::RADIUS_VALUES.filter_map do |radius|
        count = radius_links_query.count do |course|
          course.respond_to?(:minimum_distance_to_search_location) && course.minimum_distance_to_search_location.to_f <= radius
        end

        { radius:, count: } if count.positive?
      end
    end

    def course_count_translation(count:)
      if count >= MAX_COURSES_COUNT
        t(".over_100_courses")
      else
        t(".course_count", count:)
      end
    end
  end
end
