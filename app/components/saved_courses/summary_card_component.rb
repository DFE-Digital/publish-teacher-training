# frozen_string_literal: true

module SavedCourses
  class SummaryCardComponent < Courses::SummaryCardComponent
    attr_reader :saved_course, :order

    def initialize(saved_course:, location: nil, short_address: nil, order: nil)
      @saved_course = saved_course
      @order = order
      super(course: saved_course.course, location: location, short_address: short_address)
    end

    def nearest_placement_school_key
      t(".nearest_placement_school")
    end

    def title
      course_link = govuk_link_to(
        find_course_path(
          provider_code: course.provider_code,
          course_code: course.course_code,
          location: @location,
          distance_from_location: search_by_location? ? saved_course.minimum_distance_to_search_location.ceil : nil,
        ),
        class: "govuk-link",
      ) do
        safe_join([
          course.provider_name,
          tag.br,
          course.name_and_code,
        ])
      end

      safe_join([course_link, " ".html_safe, course.decorate.saved_status_tag])
    end

    def nearest_placement_school_value
      return unless search_by_location?

      t(
        ".distance_html",
        distance: content_tag(:strong, pluralize(saved_course.minimum_distance_to_search_location.ceil, "mile")),
        location: content_tag(:strong, sanitize(@short_address.presence || @location)),
      ).html_safe
    end

    def nearest_placement_school_hint
      t(".placement_hint") unless search_by_location?
    end

    def search_by_location?
      @location.present? &&
        saved_course.respond_to?(:minimum_distance_to_search_location) &&
        saved_course.minimum_distance_to_search_location.present?
    end
  end
end
