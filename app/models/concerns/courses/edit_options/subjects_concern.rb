module Courses
  module EditOptions
    module SubjectsConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in manage-courses-frontend:
        #
        # https://github.com/DFE-Digital/manage-courses-frontend/blob/master/spec/factories/courses.rb
        def potential_subjects
          ServiceContainer.new.get(:courses, :assignable_master_subjects).execute(self)
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
