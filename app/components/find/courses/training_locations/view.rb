# frozen_string_literal: true

module Find
  module Courses
    module TrainingLocations
      class View < ViewComponent::Base
        include PublishHelper
        include PreviewHelper

        attr_reader :course, :preview

        def initialize(course:, preview: false)
          @course = course
          @preview = preview
          super
        end

        def placements_url
          if preview
            placements_publish_provider_recruitment_cycle_course_path(
              course.provider_code,
              course.recruitment_cycle_year,
              course.course_code
            )
          else
            find_placements_path(course.provider_code, course.course_code)
          end
        end

        def potential_placements_text
          pluralize(course.sites.size, 'potential placement location')
        end

        def potential_study_sites_text
          return 'No study sites' if course.study_sites.none?

          pluralize(course.study_sites.size, 'potential study site')
        end
      end
    end
  end
end
