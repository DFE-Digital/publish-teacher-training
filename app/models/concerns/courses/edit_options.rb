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
    include CanSponsorStudentVisaConcern
    include CanSponsorSkilledWorkerVisaConcern

    included do
      # When changing edit options here be sure to update the edit_options in the
      # courses factory in publish-teacher-training:
      #
      # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
      def edit_course_options
        {
          entry_requirements:,
          qualifications: qualification_options,
          age_range_in_years: age_range_options,
          start_dates: start_date_options,
          study_modes: study_mode_options,
          can_sponsor_student_visas: can_sponsor_student_visa_options,
          can_sponsor_skilled_worker_visas: can_sponsor_skilled_worker_visa_options,
          show_is_send: show_is_send?,
          show_start_date: show_start_date?,
          show_applications_open: show_applications_open?,
          subjects: potential_subjects,
          modern_languages:,
          modern_languages_subject:,
        }.with_indifferent_access
      end
    end
  end
end
