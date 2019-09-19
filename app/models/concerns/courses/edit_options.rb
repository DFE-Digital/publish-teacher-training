module Courses
  module EditOptions
    extend ActiveSupport::Concern
    include AgeRangeConcern
    include EntryRequirementsConcern
    include QualificationConcern
    include StartDateConcern
    include StudyModeConcern
    include IsSendConcern
    include ApplicationsOpenConcern

    included do
      # When changing edit options here be sure to update the edit_options in the
      # courses factory in manage-courses-frontend:
      #
      # https://github.com/DFE-Digital/manage-courses-frontend/blob/master/spec/factories/courses.rb
      def edit_course_options
        {
          entry_requirements: entry_requirements,
          qualifications: qualification_options,
          age_range_in_years: age_range_options,
          start_dates: start_date_options,
          study_modes: study_mode_options,
          show_is_send: show_is_send?,
          show_start_date: show_start_date?,
          show_applications_open: show_applications_open?
        }
      end
    end
  end
end
