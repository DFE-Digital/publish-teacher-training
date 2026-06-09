# frozen_string_literal: true

class CourseWizard
  module Steps
    class VisaSponsorshipApplicationDeadlineRequired
      include DfE::Wizard::Step

      attribute :visa_sponsorship_application_deadline_required, :boolean

      validates :visa_sponsorship_application_deadline_required, inclusion: { in: [true, false], message: I18n.t("course_wizard.steps.visa_sponsorship_application_deadline_required.errors.visa_sponsorship_application_deadline_required.blank") }

      def self.permitted_params
        [:visa_sponsorship_application_deadline_required]
      end
    end
  end
end
