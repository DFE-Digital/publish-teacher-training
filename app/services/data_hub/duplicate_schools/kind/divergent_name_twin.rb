# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    class Kind
      # Same urn, two names a provider wrote. Often deliberate labelling rather
      # than an accident, so it needs asking rather than merging.
      class DivergentNameTwin < Kind
        matches { true }
        headline "one urn under two provider-written names"
        action "ask the provider which name they meant before merging"

        # A name that is neither the GIAS name nor the generic main site label
        # is one the provider typed for themselves, so it carries meaning worth
        # asking about - "Main site Secondary- one of our partner schools"
        # counts, a plain "Main Site" does not.
        flag(:provider_authored_name) do
          names.any? { |name| name != gias_name && name != Site::MAIN_SITE }
        end
        flag(:courses_on_both_sides) { sites_with_courses > 1 }
      end
    end
  end
end
