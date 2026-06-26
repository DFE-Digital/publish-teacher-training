# frozen_string_literal: true

class CourseWizard
  module Steps
    class VisaSponsorshipApplicationDeadlineRequired
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :visa_sponsorship_application_deadline_required, :boolean

      validates :visa_sponsorship_application_deadline_required, inclusion: { in: [true, false], message: I18n.t("course_wizard.steps.visa_sponsorship_application_deadline_required.errors.visa_sponsorship_application_deadline_required.blank") }

      review do |r|
        r.row(
          label: :is_there_a_visa_sponsorship_deadline,
          value: ->(draft) { draft.visa_sponsorship_application_deadline_required },
          formatter: :yes_no,
          show_when_blank: true,
        )
      end

      def self.permitted_params
        [:visa_sponsorship_application_deadline_required]
      end
    end
  end
end
