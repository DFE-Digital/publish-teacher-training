# frozen_string_literal: true

class CourseWizard
  module Steps
    class StartDate
      include DfE::Wizard::Step
      include CourseWizard::Reviewable

      attribute :start_date

      validates :start_date, presence: { message: I18n.t("course_wizard.steps.start_date.errors.start_date.blank") }

      review do |r|
        r.row label: :start_date, value: ->(draft) { draft.start_date }
      end

      # Once a start date has been picked, every month stays on offer so that a
      # date chosen earlier in the journey is still selectable on review.
      def start_date_options
        cycle_year = wizard.recruitment_cycle_year.to_i

        return Courses::CycleStartMonths.labels_for(cycle_year) if start_date.present?

        Courses::CycleStartMonths.remaining_labels_for(cycle_year)
      end

      def self.permitted_params
        [:start_date]
      end
    end
  end
end
