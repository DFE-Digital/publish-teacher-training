module GIAS
  class ProviderMatcherService
    include ServicePattern

    def initialize(provider: nil)
      @provider = provider
    end

    def call
      @recruitment_cycle = @provider.recruitment_cycle

      matches = {
        establishments: {
          # postcode: establishment_postcode_matches.to_a,
          name: establishment_name_matches.to_a,
          # site_postcode: establishment_site_postcode_matches,
        }
      }
    end

    def establishment_postcode_matches
      GIASEstablishment.where(
        "UPPER(TRIM(gias_establishment.postcode))=?", @provider.postcode.strip.upcase
      )
    end

    def establishment_name_matches
      GIASEstablishment.where(
        "LOWER(gias_establishment.name)=?", @provider.provider_name.downcase
      )
    end

    def establishment_site_postcode_matches
      @provider.sites.map do |site|
        [site,
         GIASEstablishment.where(
           "UPPER(TRIM(gias_establishment.postcode))=?",
           site.postcode.strip.upcase,
         ).to_a]
      end
        .reject { |s,e| e&.none? }
        .to_h
    end
  end
end
