module Courses
  module EditOptions
    module StudyModeOptions
      extend ActiveSupport::Concern
      included do
        def study_mode_options
          Course.study_modes.keys
        end
      end
    end
  end
end
