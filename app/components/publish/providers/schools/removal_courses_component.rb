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
            course.recruitment_cycle.year,
            course.course_code,
          )
        end

        def course_information(course)
          [
            I18n.t("publish.courses.course_table.funding.#{course.funding}"),
            course.qualifications_summary,
            course.study_mode_description.capitalize,
            start_date(course),
          ].compact_blank.join(", ")
        end

        def link_to_course?
          @link_to_course
        end

      private

        attr_reader :courses, :provider

        def start_date(course)
          return if course.start_date.blank?

          I18n.l(course.start_date.to_date, format: :short)
        end
      end
    end
  end
end
