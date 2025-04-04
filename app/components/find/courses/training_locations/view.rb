# frozen_string_literal: true

module Find
  module Courses
    module TrainingLocations
      class View < ViewComponent::Base
        include PublishHelper
        include PreviewHelper

        attr_reader :course, :coordinates, :distance_from_location, :preview

        def initialize(course:, coordinates:, distance_from_location:, preview: false)
          super
          @course = course
          @coordinates = coordinates
          @distance_from_location = distance_from_location
          @preview = preview
        end

        def placements_url
          if preview
            placements_publish_provider_recruitment_cycle_course_path(
              course.provider_code,
              course.recruitment_cycle_year,
              course.course_code,
            )
          else
            find_placements_path(course.provider_code, course.course_code)
          end
        end

        def potential_placements_text
          if coordinates
            distance_text
          else
            content_tag(:span, I18n.t(".find.courses.training_locations.view.search_help_#{course.funding}"), class: "govuk-hint govuk-!-font-size-16")
          end
        end

        def guaranteed_text
          return unless coordinates

          I18n.t(".find.courses.training_locations.view.guaranteed") if course.fee? || course.salary?
        end

        def potential_study_sites_text
          return "Not listed yet" if course.study_sites.none?

          if coordinates
            distance_text
          elsif course.study_sites.one?
            "1 study site"
          else
            "#{course.study_sites.size} potential study sites"
          end
        end

        def potential_study_sites_hint_text
          content_tag(:span, I18n.t(".find.courses.training_locations.view.potential_study_sites_hint_text"), class: "govuk-hint govuk-!-font-size-16") if course.study_sites.none?
        end

        def distance_text
          I18n.t(
            ".find.courses.training_locations.view.distance",
            distance: content_tag(:span, pluralize(distance_from_location, "mile"), class: "govuk-!-font-weight-bold"),
            location: content_tag(:span, sanitize(coordinates[:formatted_address]), class: "govuk-!-font-weight-bold"),
          ).html_safe
        end

        def top_heading
          course.fee_based? ? I18n.t(".find.courses.training_locations.view.nearest_placement_school") : I18n.t(".find.courses.training_locations.view.nearest_employing_school")
        end

        def bottom_heading
          "Where you will study"
        end

        def show_school_placements_link?
          course.provider.selectable_school?
        end
      end
    end
  end
end
