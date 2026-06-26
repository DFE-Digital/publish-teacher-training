# frozen_string_literal: true

class CourseWizard
  module Steps
    class SkilledWorkerVisa
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :can_sponsor_skilled_worker_visa, :boolean

      validates :can_sponsor_skilled_worker_visa, inclusion: { in: [true, false], message: I18n.t("course_wizard.steps.skilled_worker_visa.errors.can_sponsor_skilled_worker_visa.blank") }

      review do |r|
        r.row(
          label: :skilled_worker_visas,
          value: ->(draft) { draft.can_sponsor_skilled_worker_visa },
          format: Publish::CheckAnswers::Formatters::Bool.new(
            yes_key: "course_wizard.steps.check_answers.answers.can_sponsor",
            no_key: "course_wizard.steps.check_answers.answers.cannot_sponsor",
          ),
          show_when_blank: true,
          changeable: ->(draft) { !draft.tda? },
        )
      end

      def self.permitted_params
        [:can_sponsor_skilled_worker_visa]
      end
    end
  end
end
