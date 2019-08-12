module Courses
  module EditCourseOptions
    module StartDateOptions
      extend ActiveSupport::Concern
      included do
        def start_date_options
          recruitment_year = provider.recruitment_cycle.year.to_i

          ["August #{recruitment_year}",
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
        end
      end
    end
  end
end
