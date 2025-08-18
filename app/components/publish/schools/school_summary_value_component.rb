module Publish
  module Schools
    class SchoolSummaryValueComponent < ViewComponent::Base
      attr_reader :course

      delegate :schools_validated?, :course_code, :recruitment_cycle_year, :provider, to: :course
      delegate :provider_code, to: :provider

      def initialize(course:)
        @course = course

        super
      end

      def inset_class
        return if schools_validated?

        custom_class = if course.errors && course.errors[:sites].present?
                         "app-inset-text--error"
                       else
                         "app-inset-text--important"
                       end

        "govuk-inset-text app-inset-text--narrow-border #{custom_class}"
      end

      def enter_school_text
        if @course.sites.school.blank?
          t(".enter_schools")
        else
          t(".check_schools")
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
