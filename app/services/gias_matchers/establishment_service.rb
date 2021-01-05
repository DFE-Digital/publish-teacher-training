module GIASMatchers
  class EstablishmentService
    include ServicePattern

    def initialize(establishment: nil, provider: nil)
      @establishment = establishment
    end

    def call
      @recruitment_cycle = RecruitmentCycle.current

      matches = {
        sites: {
          postcode: site_postcode_matches.to_a,
        },
        providers: {
          postcode: provider_postcode_matches.to_a,
        }
      }
    end

    def site_postcode_matches
      @recruitment_cycle.sites.where(
        "UPPER(TRIM(site.postcode))=?", @establishment.postcode.strip.upcase
      )
    end

    def provider_postcode_matches
      @recruitment_cycle.providers.where(
        "UPPER(TRIM(provider.postcode))=?", @establishment.postcode.strip.upcase
      )
    end
  end
end
