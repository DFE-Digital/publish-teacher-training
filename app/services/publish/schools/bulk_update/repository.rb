# frozen_string_literal: true

module Publish
  module Schools
    module BulkUpdate
      # Where a bulk update's draft lives between requests: Rails.cache, keyed by
      # a state key the URL carries, exactly as the add-course wizard does
      # (CourseWizard::Repositories::Course).
      #
      # The provider, cycle and course are part of the key rather than the
      # payload, so a state key issued for one course cannot resolve against
      # another - which is what makes Draft.find safe to call with whatever the
      # URL happens to hold.
      class Repository < DfE::Wizard::Repository::Cache
        def initialize(course:, state_key:, expires_in:, cache: Rails.cache)
          super(
            cache:,
            key: self.class.cache_key(course:, state_key:),
            expires_in:,
          )
        end

        def self.cache_key(course:, state_key:)
          [
            "course_schools_bulk_update",
            course.provider_code,
            course.recruitment_cycle_year,
            course.course_code,
            state_key,
          ].join("_")
        end
      end
    end
  end
end
