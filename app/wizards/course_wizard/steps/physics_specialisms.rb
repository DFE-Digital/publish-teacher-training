# frozen_string_literal: true

class CourseWizard
  module Steps
    class PhysicsSpecialisms
      include DfE::Wizard::Step

      CAMPAIGN_NAMES = Course.campaign_names.keys.freeze

      attribute :campaign_name, :string

      validates :campaign_name,
                inclusion: { in: CAMPAIGN_NAMES, message: I18n.t("course_wizard.steps.physics_specialisms.errors.campaign_name.blank") }

      def self.permitted_params
        [:campaign_name]
      end
    end
  end
end
