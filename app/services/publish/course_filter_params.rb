# frozen_string_literal: true

module Publish
  # The query string params the publish course list accepts, mirroring
  # Find::SearchParams. Each filter group is multi-select, so each arrives as an
  # array.
  class CourseFilterParams
    PERMITTED = [CourseFilterForm::GROUPS.index_with { [] }].freeze

    def self.permit(params)
      params.permit(*PERMITTED)
    end
  end
end
