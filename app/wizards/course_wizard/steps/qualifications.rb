# frozen_string_literal: true

class CourseWizard
  module Steps
    class Qualifications
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :qualification, :string

      validates :qualification,
                presence: { message: I18n.t("course_wizard.steps.qualifications.errors.qualification.blank") }
      validates :qualification,
                inclusion: {
                  in: ->(step) { step.qualification_options },
                  message: I18n.t("course_wizard.steps.qualifications.errors.qualification.blank"),
                },
                allow_blank: true

      review do |r|
        r.row label: :qualification, value: ->(draft) { draft.qualification }, formatter: :qualification
      end

      def review_rows(draft)
        rows = super
        return rows unless draft.tda?

        rows + [
          CourseWizard::Reviewable::RowSpec.new(
            step_id: :funding_type,
            label_key: :funding_type,
            label_options: {},
            value: draft.funding,
            formatter: :funding,
            show_when_blank: true,
            changeable: false,
          ),
          CourseWizard::Reviewable::RowSpec.new(
            step_id: :study_pattern,
            label_key: :study_pattern,
            label_options: {},
            value: draft.study_patterns_for_display,
            formatter: :study_pattern,
            show_when_blank: true,
            changeable: false,
          ),
        ]
      end

      def qualification_options
        return qualifications_without_qts if wizard&.state_store&.further_education_level?

        qualifications_with_qts
      end

      def qualifications_with_qts
        Course.qualifications.keys.grep(/qts/).sort
      end

      def qualifications_without_qts
        Course.qualifications.keys.reject { |option| option.include?("qts") }
      end

      def self.permitted_params
        [:qualification]
      end
    end
  end
end
