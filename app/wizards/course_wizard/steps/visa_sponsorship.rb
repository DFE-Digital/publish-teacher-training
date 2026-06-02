# frozen_string_literal: true

class CourseWizard
  module Steps
    class VisaSponsorship
      include DfE::Wizard::Step
      VISA_SPONSORSHIP_OPTIONS = %w[yes no].freeze

      attribute :can_sponsor_student_visa

      validates :can_sponsor_student_visa, inclusion: { in: VISA_SPONSORSHIP_OPTIONS, message: I18n.t("course_wizard.steps.visa_sponsorship.errors.can_sponsor_student_visa.blank") }

      def question
        if wizard.provider.university? || wizard.provider.scitt?
          I18n.t("course_wizard.steps.visa_sponsorship.questions.organisation")
        else
          I18n.t("course_wizard.steps.visa_sponsorship.questions.availability")
        end
      end

      def show_recruiting_from_overseas_guidance?
        (wizard.provider.university? || wizard.provider.scitt?) && !wizard.provider.can_sponsor_student_visa
      end

      def show_accrediting_provider_inset_text?
        !wizard.provider.university? && !wizard.provider.scitt? && accrediting_provider.present?
      end

      def accrediting_provider_name
        accrediting_provider&.provider_name
      end

      def accrediting_provider_can_sponsor_student_visa?
        accrediting_provider&.can_sponsor_student_visa?
      end

      def self.permitted_params
        [:can_sponsor_student_visa]
      end

    private

      def accrediting_provider
        wizard.accrediting_provider
      end
    end
  end
end
