# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      # Course list on the school removal page: name/code plus funding,
      # qualification, study mode and start date. When the school is the only
      # placement school on a course, names link to the course description tab.
      class RemovalCoursesComponent < ViewComponent::Base
        def initialize(courses:, provider:, link_to_course: false)
          super()

          @courses = courses
          @provider = provider
          @link_to_course = link_to_course
        end

        def course_path(course)
          helpers.publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            provider.recruitment_cycle.year,
            course.course_code,
          )
        end

        def course_information(course)
          labels = ::Courses::InformationLabels.new(course)

          [labels.funding, labels.qualification, labels.study_mode, labels.start_date].compact_blank.join(", ")
        end

        def link_to_course?
          @link_to_course
        end

      private

        attr_reader :courses, :provider
      end
    end
  end
end
