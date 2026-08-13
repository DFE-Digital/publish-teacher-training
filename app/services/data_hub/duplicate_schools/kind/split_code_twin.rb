# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    class Kind
      # One school under two codes: two Provider::School rows, so the provider
      # sees the same name twice with its courses split between them.
      class SplitCodeTwin < Kind
        matches { names.one? }
        headline "one school held under two codes - listed twice, courses split"
        action "merge onto the code holding more courses, moving the rest across"

        flag(:courses_on_both_sides) { sites_with_courses > 1 }
      end
    end
  end
end
