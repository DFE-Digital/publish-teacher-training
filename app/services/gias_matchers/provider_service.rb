module GIASMatchers
  class ProviderService
    include ServicePattern

    def initialize(provider: nil)
      @provider = provider
    end

    def call
      @recruitment_cycle = @provider.recruitment_cycle

      matches = {
        sites: {
          postcode: site_postcode_matches.to_a,
        },
        establishments: {
          postcode: provider_postcode_matches.to_a,
        }
      }
    end

    def site_postcode_matches
      @recruitment_cycle.sites.where(
        "UPPER(TRIM(site.postcode))=?", @provider.postcode.strip.upcase
      )
    end

    def provider_postcode_matches
      GIASEstablishment.where(
        "UPPER(TRIM(gias_establishment.postcode))=?", @provider.postcode.strip.upcase
      )
    end
  end
end
