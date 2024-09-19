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
          if course.fee_based?
            pluralize(course.sites.size, 'potential placement location')
          else
            pluralize(course.sites.size, 'potential employing school')
          end
        end

        def potential_study_sites_text
          return 'Not listed yet' if course.study_sites.none?

          if course.study_sites.one?
            '1 study site'
          else
            "#{course.study_sites.size} potential study sites"
          end
        end

        def top_heading
          course.fee_based? ? 'Placement schools' : 'Employing schools'
        end

        def bottom_heading
          'Where you will study'
        end
      end
    end
  end
end
