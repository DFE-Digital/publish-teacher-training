# frozen_string_literal: true

class CourseWizard
  module Steps
    class StudyPattern
      include DfE::Wizard::Step

      STUDY_PATTERN_OPTIONS = %w[full_time part_time].freeze

      attribute :study_pattern

      validate :study_pattern_selected
      validate :study_pattern_values_are_valid

      def study_pattern_options
        STUDY_PATTERN_OPTIONS
      end

      def self.permitted_params
        [{ study_pattern: [] }]
      end

      def selected_study_patterns
        Array(study_pattern).compact_blank
      end

    private

      def study_pattern_selected
        return if selected_study_patterns.any?

        errors.add(:study_pattern, I18n.t("course_wizard.steps.study_pattern.errors.study_pattern.blank"))
      end

      def study_pattern_values_are_valid
        invalid_values = selected_study_patterns - STUDY_PATTERN_OPTIONS
        return if invalid_values.empty?

        errors.add(:study_pattern, I18n.t("course_wizard.steps.study_pattern.errors.study_pattern.blank"))
      end
    end
  end
end
