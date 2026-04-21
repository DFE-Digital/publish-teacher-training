# frozen_string_literal: true

# Writes the legacy Site row for a provider-school addition. Kept isolated
# from ProviderSchools::Creator so the old write path can be removed in a
# single step once the new model is switched on.
module ProviderSchools
  class LegacySiteCreator
    include ServicePattern

    def initialize(site:)
      @site = site
    end

    def call
      @site.save!
      @site
    end
  end
end
