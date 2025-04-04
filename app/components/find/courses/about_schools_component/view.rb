# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class View < ViewComponent::Base
        include PublishHelper
        include PreviewHelper

        attr_reader :course, :coordinates, :distance_from_location, :preview

        delegate :published_how_school_placements_work,
                 :program_type,
                 :study_sites,
                 :site_statuses, to: :course

        def initialize(course, coordinates, distance_from_location, preview: false)
          super
          @course = course
          @coordinates = coordinates
          @distance_from_location = distance_from_location
          @preview = preview
        end

        def render?
          @course.training_locations? || preview?(params)
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
      end
    end
  end
end
