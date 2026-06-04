# frozen_string_literal: true

class CourseWizard
  module Steps
    class VisaSponsorship
      include DfE::Wizard::Step

      attribute :can_sponsor_student_visa, :boolean

      validates :can_sponsor_student_visa, inclusion: { in: [true, false], message: I18n.t("course_wizard.steps.visa_sponsorship.errors.can_sponsor_student_visa.blank") }

      def can_sponsor_student_visa
        return super unless super.nil? && default_to_no_from_accrediting_provider?

        false
      end

      def question
        if wizard.provider.accredited?
          I18n.t("course_wizard.steps.visa_sponsorship.questions.organisation")
        else
          I18n.t("course_wizard.steps.visa_sponsorship.questions.availability")
        end
      end

      def show_recruiting_from_overseas_guidance?
        wizard.provider.accredited? && !wizard.provider.can_sponsor_student_visa
      end

      def show_accrediting_provider_inset_text?
        !wizard.provider.accredited? && accrediting_provider.present?
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

      def default_to_no_from_accrediting_provider?
        show_accrediting_provider_inset_text? && !accrediting_provider_can_sponsor_student_visa?
      end

      def accrediting_provider
        wizard.accreditation.accrediting_provider
      end
    end
  end
end
