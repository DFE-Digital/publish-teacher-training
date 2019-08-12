module Courses
  module EditCourseOptions
    module EntryRequirements
      extend ActiveSupport::Concern
      included do
        def entry_requirements
          Course::ENTRY_REQUIREMENT_OPTIONS
            .reject { |k, _v| %i[not_set not_required].include?(k) }
            .keys
        end
      end
    end
  end
end
