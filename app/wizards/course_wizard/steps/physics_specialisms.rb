# frozen_string_literal: true

class CourseWizard
  module Steps
    class PhysicsSpecialisms
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      CAMPAIGN_NAMES = Course.campaign_names.keys.freeze

      attribute :campaign_name, :string

      validates :campaign_name,
                inclusion: { in: CAMPAIGN_NAMES, message: I18n.t("course_wizard.steps.physics_specialisms.errors.campaign_name.blank") }

      review do |r|
        r.row(
          label: :engineers,
          value: ->(draft) { draft.campaign_name == "engineers_teach_physics" },
          format: Publish::CheckAnswers::Formatters::Bool.new(
            yes_key: "course_wizard.steps.check_answers.answers.yes",
            no_key: "course_wizard.steps.check_answers.answers.no",
          ),
        )
      end

      def self.permitted_params
        [:campaign_name]
      end
    end
  end
end
