# app/services/courses/radius_quick_link_suggestions.rb
module Courses
  class RadiusQuickLinkSuggestions
    MAX_COURSES_COUNT = 100

    def initialize(params:, i18n_scope:, request_query:, search_form: SearchForm, query_service: Query)
      @params = params
      @i18n_scope = i18n_scope
      @request_query = request_query
      @search_form = search_form
      @query_service = query_service
    end

    def call
      bucket_counts
        .slice_after { |it| it[:count].to_i >= MAX_COURSES_COUNT }
        .first
        .to_a
        .map { |values| build_link(values) }
    end

    def bucket_counts
      courses = @query_service.call(params: params_with_max_radius).limit(MAX_COURSES_COUNT + 1)

      @search_form.radius_values.filter_map do |radius|
        count = courses.count { |course| within_radius?(course, radius) }
        { radius:, count: } if count.positive?
      end
    end

    def build_link(values)
      {
        text: translate("radius_in_miles", count: values[:radius], course_count: format_course_count(values[:count])),
        url: find_results_path(values[:radius]),
      }
    end

    def params_with_max_radius
      @params.merge(radius: @search_form.radius_values.max)
    end

    def within_radius?(course, radius)
      course.respond_to?(:minimum_distance_to_search_location) &&
        course.minimum_distance_to_search_location.to_f <= radius
    end

    def format_course_count(count)
      key = count >= MAX_COURSES_COUNT ? "over_100_courses" : "course_count"
      translate(key, count:)
    end

    def find_results_path(radius)
      query = @request_query.dup
      query["radius"] = radius
      Rails.application.routes.url_helpers.find_results_path(**query)
    end

    def translate(key, **options)
      I18n.t("#{@i18n_scope}.#{key}", **options)
    end
  end
end
