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
      provider_span = content_tag(:span, course.provider_name)
      course_span = content_tag(:span, course.name_and_code)
      status_tag = course.decorate.saved_status_tag
      status_block = (content_tag(:div, status_tag, class: "app-saved-course__status-tag") if status_tag.present?)

      title_inner = safe_join(
        [
          provider_span,
          tag.br,
          course_span,
          status_block,
        ].compact,
      )

      course_info =
        govuk_link_to(
          find_course_path(provider_code: course.provider_code, course_code: course.course_code),
          class: "govuk-link",
        ) { title_inner }

      content_tag(:div, class: "app-saved-course__card-title") do
        safe_join(
          [
            content_tag(:div, course_info),
          ],
        )
      end
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
