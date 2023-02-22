# frozen_string_literal: true

module Courses
  module EditOptions
    module EntryRequirementsConcern
      extend ActiveSupport::Concern
      included do
        def entry_requirements
          Course::ENTRY_REQUIREMENT_OPTIONS
            .keys
            .reject { |option| option.in? %i[not_set not_required] }
        end
      end
    end
  end
end
