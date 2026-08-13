# frozen_string_literal: true

module DataHub
  module DuplicateSchools
    class Kind
      # The same school added repeatedly under one code. Provider::School's
      # unique (provider_id, gias_school_id, site_code) index already collapsed
      # these, so they are legacy litter rather than anything a provider sees.
      class Clone < Kind
        matches { codes.one? && names.one? }
        headline "the same school added repeatedly under one code"
        action "safe to merge unattended - no user-visible duplicate to remove"
      end
    end
  end
end
