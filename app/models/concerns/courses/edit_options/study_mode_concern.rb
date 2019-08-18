module Courses
  module EditOptions
    module StudyModeConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in manage-courses-frontend:
        #
        # https://github.com/DFE-Digital/manage-courses-frontend/blob/master/spec/factories/courses.rb
        def study_mode_options
          Course.study_modes.keys
        end
      end
    end
  end
end
