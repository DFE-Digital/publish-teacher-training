# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    class Kind
      # The provider's main site and the same school added again as a placement
      # school - the shape the original query's `code <> '-'` filter hid. Which
      # row should survive is a policy decision, so nothing here assumes one.
      class MainSiteCollision < Kind
        matches { codes.include?(Provider::School::MAIN_SITE_CODE) }
        headline "the provider's main site and the same school added again as a placement school"
        action "decide the policy: keep '-' and move courses onto it, or keep the named row"

        flag(:main_site_at_risk) { legacy_primary.code != Provider::School::MAIN_SITE_CODE }
        flag(:courses_on_both_sides) { sites_with_courses > 1 }
      end
    end
  end
end
