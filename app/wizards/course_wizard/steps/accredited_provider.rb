# frozen_string_literal: true

class CourseWizard
  module Steps
    class AccreditedProvider
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :accredited_provider_code, :string

      validates :accredited_provider_code, presence: { message: I18n.t("course_wizard.steps.accredited_provider.errors.accredited_provider_code.blank") }

      def review_rows(draft)
        provider = draft.accrediting_provider
        return [] if provider.blank?

        [
          CourseWizard::Reviewable::RowSpec.new(
            step_id: step_id,
            label_key: :accredited_provider,
            label_options: {},
            value: provider.provider_name,
            formatter: nil,
            show_when_blank: true,
            changeable: wizard.saved?(:accredited_provider),
          ),
        ]
      end

      def accredited_partners
        wizard.accreditation.partners
      end

      def self.permitted_params
        [:accredited_provider_code]
      end
    end
  end
end
