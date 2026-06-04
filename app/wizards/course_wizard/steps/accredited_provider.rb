# frozen_string_literal: true

class CourseWizard
  module Steps
    class AccreditedProvider
      include DfE::Wizard::Step

      attribute :accredited_provider_code, :string

      validates :accredited_provider_code, presence: { message: I18n.t("course_wizard.steps.accredited_provider.errors.accredited_provider_code.blank") }

      def accredited_partners
        wizard.accreditation.partners
      end

      def self.permitted_params
        [:accredited_provider_code]
      end
    end
  end
end
