module API
  class RadiusQuickLinkSuggestionsController < PublicAPIController
    MAX_COURSES_COUNT = 100

    def index
      @search_params = params.to_unsafe_h.except(:controller, :action)

      return render_json_error(status: 400, message: I18n.t(".api.radius_query_link_suggestions.errors.bad_request")) if @search_params.blank?

      render json: no_results_quick_links
    end

  private

    def no_results_quick_links
      result = []

      valid_buckets = bucket_counts_from_largest_search_radius.slice_after { |it| it[:count].to_i >= MAX_COURSES_COUNT }.first
      return result if valid_buckets.blank?

      valid_buckets.each do |it|
        radius = it[:radius]
        count = it[:count]

        text = I18n.t(
          ".api.radius_query_link_suggestions.radius_in_miles",
          count: radius,
          miles: I18n.t(".api.radius_query_link_suggestions.miles", count: radius),
          course_count: course_count_translation(count),
        )

        result << {
          text: text,
          url: find_results_path(**@search_params, radius: radius),
        }
      end

      result
    end

    def bucket_counts_from_largest_search_radius
      radius_links_query = ::Courses::Query.call(params: @search_params.merge(radius: 200)).limit(MAX_COURSES_COUNT + 1)
      radius_buckets = Courses::SearchForm::RADIUS_VALUES

      radius_buckets.filter_map do |radius|
        count = radius_links_query.count { |course| course.minimum_distance_to_search_location.to_f <= radius }
        { radius: radius, count: count } if count.positive?
      end
    end

    def course_count_translation(count)
      if count >= MAX_COURSES_COUNT
        I18n.t(".api.radius_query_link_suggestions.over_100_courses")
      else
        I18n.t(".api.radius_query_link_suggestions.course_count",
               course_count: count,
               course_word: I18n.t(".api.radius_query_link_suggestions.course_word", count: count))
      end
    end
  end
end
