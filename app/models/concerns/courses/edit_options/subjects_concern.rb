module Courses
  module EditOptions
    module SubjectsConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in publish-teacher-training:
        #
        # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
        def potential_subjects
          self.assignable_master_subjects&.sort_by(&:subject_name)
        end

        def available_modern_languages
          return unless has_the_modern_languages_secondary_subject_type?
          return unless level == "secondary"

          ModernLanguagesSubject.all
        end
      end
    end
  end
end
