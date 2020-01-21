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
    include SubjectsConcern

    included do
      # When changing edit options here be sure to update the edit_options in the
      # courses factory in publish-teacher-training:
      #
      # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
      def edit_course_options
        {
          entry_requirements: entry_requirements,
          qualifications: qualification_options,
          age_range_in_years: age_range_options,
          start_dates: start_date_options,
          study_modes: study_mode_options,
          show_is_send: show_is_send?,
          show_start_date: show_start_date?,
          show_applications_open: show_applications_open?,
          subjects: potential_subjects,
          modern_languages: available_modern_languages,
        }
      end
    end
  end
end
