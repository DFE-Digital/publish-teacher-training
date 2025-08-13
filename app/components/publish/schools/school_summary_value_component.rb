module Publish
  module Schools
    class SchoolSummaryValueComponent < ViewComponent::Base
      attr_reader :course

      delegate :course_code, :recruitment_cycle_year, :provider, to: :course
      delegate :provider_code, to: :provider

      def initialize(course:)
        @course = course

        super
      end

      def inset_class
        if course.errors && course.errors[:sites].present?
          "app-inset-text--error"
        else
          "app-inset-text--important"
        end
      end

      def enter_school_text
        if @course.sites.school.blank?
          "Enter schools for this course"
        else
          "Check the schools for this course"
        end
      end

      def enter_school_link
        schools_publish_provider_recruitment_cycle_course_path(
          provider_code,
          recruitment_cycle_year,
          course_code,
          extra_link_arguments,
        )
      end

      def extra_link_arguments
        { display_errors: true } if course.errors.present?
      end
    end
  end
end
