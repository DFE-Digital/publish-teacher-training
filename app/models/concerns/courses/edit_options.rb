module Courses
  module EditOptions
    extend ActiveSupport::Concern
    include AgeRangeConcern
    include EntryRequirementsConcern
    include QualificationConcern
    include StartDateConcern
    include StudyModeConcern
    included do
      def edit_course_options
        {
          entry_requirements: entry_requirements,
          qualifications: qualification_options,
          age_range_in_years: age_range_options,
          start_dates: start_date_options,
          study_modes: study_mode_options,
        }
      end
    end
  end
end
