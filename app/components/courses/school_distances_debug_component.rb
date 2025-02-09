# frozen_string_literal: true

module Courses
  class SchoolDistancesDebugComponent < ViewComponent::Base
    attr_reader :course, :latitude, :longitude

    def initialize(course:, latitude:, longitude:, debug:, environment_name: Settings.environment.name)
      @course = course
      @latitude = latitude
      @longitude = longitude
      @debug = debug
      @environment_name = ActiveSupport::StringInquirer.new(environment_name)

      super
    end

    def render?
      @debug.present? && (
        @environment_name.qa? || @environment_name.development? || @environment_name.review?
      ) && (
        @latitude.present? && @longitude.present?
      )
    end

    def schools
      ::Courses::SchoolDistancesQuery.new(courses: [course], latitude:, longitude:).call
    end

    GOOGLE_MAPS_BASE_URL = 'https://www.google.com/maps/dir/'

    def google_maps_direction_path(school_latitude:, school_longitude:)
      start_point = "#{@latitude},#{@longitude}"
      waypoint = "#{school_latitude},#{school_longitude}"

      "#{GOOGLE_MAPS_BASE_URL}#{start_point}/#{waypoint}"
    end
  end
end
