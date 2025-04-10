# frozen_string_literal: true

module Courses
  class QueryDebugHeaderComponent < ViewComponent::Base
    attr_reader :latitude, :longitude

    def initialize(results:, applied_filters:, debug:, latitude:, longitude:, environment_name: Settings.environment.name)
      @results = results
      @applied_filters = applied_filters
      @debug = ActiveModel::Type::Boolean.new.cast(debug)
      @environment_name = ActiveSupport::StringInquirer.new(environment_name)
      @latitude = latitude
      @longitude = longitude

      super
    end

    def render?
      @debug.present? && (
        @environment_name.qa? || @environment_name.development? || @environment_name.review?
      )
    end

    def search_by_location?
      @latitude.present? && @longitude.present?
    end

    def nearest_school_for_each_result
      @nearest_school_for_each_result ||= ::Courses::NearestSchoolQuery.new(
        courses: @results,
        latitude:,
        longitude:,
      ).call
    end

    def unique_nearest_school_for_each_result
      nearest_school_for_each_result.uniq { |site| [site.latitude, site.longitude] }
    end

    GOOGLE_MAPS_BASE_URL = "https://www.google.com/maps/dir/"

    def google_maps_directions_path
      start_point = "#{@latitude},#{@longitude}"

      "#{GOOGLE_MAPS_BASE_URL}#{start_point}"
    end

    def google_maps_direction_path_from_the_centre(result)
      "#{google_maps_directions_path}/#{result.latitude},#{result.longitude}"
    end
  end
end
