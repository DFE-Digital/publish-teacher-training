module Support
  module Providers
    class ManualRolloverForm < ApplicationForm
      attr_accessor :confirmation, :environment, :course_codes, :provider

      CONFIRM_ROLLOVER = "confirm manual rollover".freeze
      NO_COURSES = "none".freeze

      validates :confirmation, :environment, presence: true
      validate :must_confirm_rollover, :must_confirm_environment
      validate :must_choose_courses, if: -> { courses.any? }

      def courses
        @courses ||= provider.courses.order(:name, :course_code).to_a
      end

      def chosen_course_codes
        selected_course_codes.excluding(NO_COURSES)
      end

    private

      def selected_course_codes
        Array(course_codes).compact_blank.uniq
      end

      def must_confirm_rollover
        if confirmation.present? && confirmation != CONFIRM_ROLLOVER
          errors.add(:confirmation, :invalid_confirmation)
        end
      end

      def must_confirm_environment
        if environment.present? && environment != Settings.environment.name
          errors.add(:environment, :invalid_environment)
        end
      end

      def must_choose_courses
        if selected_course_codes.empty?
          errors.add(:course_codes, :blank)
        elsif selected_course_codes.include?(NO_COURSES) && selected_course_codes.many?
          errors.add(:course_codes, :no_courses_and_courses)
        elsif chosen_course_codes.difference(courses.map(&:course_code)).any?
          errors.add(:course_codes, :inclusion)
        end
      end
    end
  end
end
