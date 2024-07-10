# frozen_string_literal: true

module Find
  module Courses
    module AboutSchoolsComponent
      class View < ViewComponent::Base
        include PublishHelper
        include PreviewHelper

        attr_reader :course, :preview

        delegate :published_how_school_placements_work,
                 :program_type,
                 :study_sites,
                 :site_statuses, to: :course

        def initialize(course, preview: false)
          super
          @course = course
          @preview = preview
        end

        def render?
          published_how_school_placements_work.present? ||
            program_type.in?(%w[higher_education_programme scitt_programme]) ||
            study_sites.any? ||
            site_statuses.map(&:site).uniq.many? || preview?(params)
        end

        def show_higher_education_guidance?
          return false unless course.higher_education_programme?

          course_information_config.show_placement_guidance?(:program_type)
        end

        def show_scitt_guidance?
          return false unless course.scitt_programme?

          course_information_config.show_placement_guidance?(:program_type)
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

        private

        def course_information_config
          @course_information_config ||= Configs::CourseInformation.new(course)
        end
      end
    end
  end
end
