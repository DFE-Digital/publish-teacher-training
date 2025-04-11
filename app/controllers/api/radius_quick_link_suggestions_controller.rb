# frozen_string_literal: true

module API
  class RadiusQuickLinkSuggestionsController < PublicAPIController
    include ActionView::Helpers::NumberHelper

    def index
      @search_params = params.to_unsafe_h.with_indifferent_access.except(:controller, :action)
      results = no_results_quick_links

      render json: results
    end

    def no_results_quick_links
      result = []
      over_limit_displayed = false

      bucket_counts_from_largest_search_radius.each do |row|
        radius = row["radius"].to_i
        count = row["count"].to_i

        if count > 100 && !over_limit_displayed
          result << {
            text: "#{number_with_delimiter(radius)} #{'mile'.pluralize(radius)} (#{number_with_delimiter(100)}+ #{'course'.pluralize(100)})",
            url: find_results_path(**@search_params, radius: radius),
          }
          over_limit_displayed = true
          break
        elsif count <= 100
          result << {
            text: "#{number_with_delimiter(radius)} #{'mile'.pluralize(radius)} (#{number_with_delimiter(count)} #{'course'.pluralize(count)})",
            url: find_results_path(**@search_params, radius: radius),
          }
        end
      end

      result
    end

    def bucket_counts_from_largest_search_radius
      radius_links_query = ::Courses::Query.call(params: @search_params.merge(radius: 200)).limit(101)
      radius_buckets = Courses::SearchForm::RADIUS_VALUES

      raw_counts = radius_buckets.map do |radius|
        count = radius_links_query.count { |course| course.minimum_distance_to_search_location.to_f <= radius }
        { "radius" => radius, "count" => count }
      end

      raw_counts.select { |row| row["count"].positive? }
    end
  end
end
