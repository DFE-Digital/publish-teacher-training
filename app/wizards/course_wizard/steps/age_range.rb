# frozen_string_literal: true

class CourseWizard
  module Steps
    class AgeRange
      include DfE::Wizard::Step

      CUSTOM_AGE_RANGE_VALIDATOR = Courses::ValidateCustomAgeRangeService

      attribute :age_range_in_years, :string
      attribute :course_age_range_in_years_other_from, :string
      attribute :course_age_range_in_years_other_to, :string

      validates :age_range_in_years, presence: { message: I18n.t("course_wizard.steps.age_range.errors.age_range_in_years.blank") }

      with_options if: :age_range_other? do
        validates :course_age_range_in_years_other_from, numericality: {
          only_integer: true,
          allow_blank: true,
          greater_than_or_equal_to: CUSTOM_AGE_RANGE_VALIDATOR::MIN_FROM_AGE,
          less_than_or_equal_to: CUSTOM_AGE_RANGE_VALIDATOR::MAX_FROM_AGE,
        }
        validates :course_age_range_in_years_other_to, numericality: {
          only_integer: true,
          allow_blank: true,
          greater_than_or_equal_to: CUSTOM_AGE_RANGE_VALIDATOR::MIN_TO_AGE,
          less_than_or_equal_to: CUSTOM_AGE_RANGE_VALIDATOR::MAX_TO_AGE,
        }
        validate :age_range_from_and_to_missing
        validate :validate_custom_age_range
      end

      def primary_age_range_options
        %w[3_to_7 5_to_11 7_to_11 7_to_14]
      end

      def secondary_age_range_options
        %w[11_to_16 11_to_18 14_to_19]
      end

      def preset_options
        wizard.state_store.primary_level? ? primary_age_range_options : secondary_age_range_options
      end

      def self.permitted_params
        %i[age_range_in_years course_age_range_in_years_other_from course_age_range_in_years_other_to]
      end

    private

      def age_range_other?
        age_range_in_years == "other"
      end

      def age_range_from_and_to_missing
        return unless age_range_in_years == "other"

        errors.add(:course_age_range_in_years_other_from, :blank) if course_age_range_in_years_other_from.blank?

        errors.add(:course_age_range_in_years_other_to, :blank) if course_age_range_in_years_other_to.blank?
      end

      def validate_custom_age_range
        return if errors[:course_age_range_in_years_other_from].present? || errors[:course_age_range_in_years_other_to].present?

        CUSTOM_AGE_RANGE_VALIDATOR.new.execute(combined_age_range, self)
      end

      def combined_age_range
        "#{course_age_range_in_years_other_from}_to_#{course_age_range_in_years_other_to}"
      end
    end
  end
end
