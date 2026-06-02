# frozen_string_literal: true

class CourseWizard
  module Steps
    class StartDate
      include DfE::Wizard::Step

      attribute :start_date

      validates :start_date, presence: { message: I18n.t("course_wizard.steps.start_date.errors.start_date.blank") }

      def start_date_options
        cycle_year = wizard.provider.recruitment_cycle.year.to_i
        options = (1..12).map { |m| "#{Date::MONTHNAMES[m]} #{cycle_year}" } +
          (1..7).map { |m| "#{Date::MONTHNAMES[m]} #{cycle_year + 1}" }

        return options if persisted?

        index = options.index(sliced_label_for_today(cycle_year))

        index.blank? ? options : options[index..]
      end

      def self.permitted_params
        [:start_date]
      end

    private

      def sliced_label_for_today(cycle_year)
        today = Time.zone.today
        january_label = january_label_for(cycle_year)

        if today.year < cycle_year
          # We're before January starts, so slice at "January <cycle_year>"
          january_label
        elsif today.year == cycle_year
          # In cycle year, slice at the actual month
          "#{Date::MONTHNAMES[today.month]} #{cycle_year}"
        else
          # Default to first month
          january_label
        end
      end

      def january_label_for(cycle_year)
        "#{Date::MONTHNAMES[1]} #{cycle_year}"
      end
    end
  end
end
