# frozen_string_literal: true

module Courses
  module EditOptions
    module StartDateConcern
      extend ActiveSupport::Concern

      included do
        # A persisted course keeps every month on offer, because #validate_start_date
        # checks the saved start date against this list and an existing course may
        # legitimately have started already.
        def start_date_options
          cycle_year = provider.recruitment_cycle.year.to_i

          return Courses::CycleStartMonths.labels_for(cycle_year) if persisted?

          Courses::CycleStartMonths.remaining_labels_for(cycle_year)
        end

        def show_start_date?
          !is_published?
        end
      end
    end
  end
end
