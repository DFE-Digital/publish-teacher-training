module Courses
  module EditOptions
    module EntryRequirementsConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in publish-teacher-training:
        #
        # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
        def entry_requirements
          Course::ENTRY_REQUIREMENT_OPTIONS
            .keys
            .reject { |option| option.in? %i[not_set not_required] }
        end
      end
    end
  end
end
