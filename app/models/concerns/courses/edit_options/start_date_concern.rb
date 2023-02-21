# frozen_string_literal: true

module Courses
  module EditOptions
    module StartDateConcern
      extend ActiveSupport::Concern
      included do
        def start_date_options
          recruitment_year = provider.recruitment_cycle.year.to_i

          available_options = ["October #{recruitment_year - 1}",
                               "November #{recruitment_year - 1}",
                               "December #{recruitment_year - 1}",

                               "January #{recruitment_year}",
                               "February #{recruitment_year}",
                               "March #{recruitment_year}",
                               "April #{recruitment_year}",
                               "May #{recruitment_year}",
                               "June #{recruitment_year}",
                               "July #{recruitment_year}",
                               "August #{recruitment_year}",
                               "September #{recruitment_year}",
                               "October #{recruitment_year}",
                               "November #{recruitment_year}",
                               "December #{recruitment_year}",

                               "January #{recruitment_year + 1}",
                               "February #{recruitment_year + 1}",
                               "March #{recruitment_year + 1}",
                               "April #{recruitment_year + 1}",
                               "May #{recruitment_year + 1}",
                               "June #{recruitment_year + 1}",
                               "July #{recruitment_year + 1}"]

          if instance_of?(Course) && persisted?
            available_options
          else
            starting_index = available_options.find_index "#{Date::MONTHNAMES[DateTime.now.month]} #{DateTime.now.year}"

            available_options[starting_index..available_options.size]
          end
        end

        def show_start_date?
          !is_published?
        end
      end
    end
  end
end
