# frozen_string_literal: true

module Courses
  module EditOptions
    module StartDateConcern
      extend ActiveSupport::Concern

      included do
        def start_date_options
          cycle_year = provider.recruitment_cycle.year.to_i
          options = (1..12).map { |m| "#{Date::MONTHNAMES[m]} #{cycle_year}" } +
            (1..7).map { |m| "#{Date::MONTHNAMES[m]} #{cycle_year + 1}" }

          return options if persisted?

          index = options.index(sliced_label_for_today(cycle_year))

          index.blank? ? options : options[index..]
        end

        def show_start_date?
          !is_published?
        end

      private

        def sliced_label_for_today(cycle_year)
          today = Time.zone.today

          if today.year < cycle_year
            # We're before January starts, so slice at "January <cycle_year>"
            "#{Date::MONTHNAMES[1]} #{cycle_year}"
          elsif today.year == cycle_year
            # In cycle year, slice at the actual month
            "#{Date::MONTHNAMES[today.month]} #{cycle_year}"
          else
            # Default to first month
            "#{Date::MONTHNAMES[1]} #{cycle_year}"
          end
        end
      end
    end
  end
end
