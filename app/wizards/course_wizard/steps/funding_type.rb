# frozen_string_literal: true

class CourseWizard
  module Steps
    class FundingType
      include DfE::Wizard::Step

      FUNDING_TYPE_OPTIONS = %w[fee salary apprenticeship].freeze

      attribute :funding_type, :string

      validates :funding_type,
                presence: { message: I18n.t("course_wizard.steps.funding_type.errors.funding_type.blank") }

      validates :funding_type,
                inclusion: {
                  in: FUNDING_TYPE_OPTIONS,
                  message: I18n.t("course_wizard.steps.funding_type.errors.funding_type.blank"),
                },
                allow_blank: true

      def funding_type_options
        FUNDING_TYPE_OPTIONS
      end

      def self.permitted_params
        [:funding_type]
      end
    end
  end
end
