# frozen_string_literal: true

class CourseWizard
  module Steps
    class SkilledWorkerVisa
      include DfE::Wizard::Step

      attribute :can_sponsor_skilled_worker_visa, :boolean

      validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: I18n.t("course_wizard.steps.skilled_worker_visa.errors.can_sponsor_skilled_worker_visa.blank") }

      def can_sponsor_skilled_worker_visa
        return super unless super.nil?

        false
      end

      def self.permitted_params
        [:can_sponsor_skilled_worker_visa]
      end
    end
  end
end
