# frozen_string_literal: true

class CourseWizard
  module Steps
    class Qualifications
      include DfE::Wizard::Step

      attribute :qualification, :string

      validates :qualification,
                presence: { message: I18n.t("course_wizard.steps.qualifications.errors.qualification.blank") }
      validates :qualification,
                inclusion: {
                  in: ->(step) { step.qualification_options },
                  message: I18n.t("course_wizard.steps.qualifications.errors.qualification.blank"),
                },
                allow_blank: true

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
