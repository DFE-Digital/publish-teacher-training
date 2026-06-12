module DataHub
  module RemoveProviderSchools
    class SiteFilter
      # Candidate sites to remove: a provider's school sites, excluding the URNs
      # we are keeping and the provider's main site (which never carries a keep URN).
      def self.filter(provider:, keep_urns:)
        provider
          .sites # already scoped to site_type: :school and .kept
          .where.not(urn: keep_urns)
          .where("TRIM(LOWER(site.location_name)) NOT SIMILAR TO '%main[ -]?site%'")
      end
    end
  end
end
