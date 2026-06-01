module DataHub
  module RemoveProviderSchools
    class DryRunSiteDiscarder
      Result = Struct.new(:site_id, :urn, :location_name, keyword_init: true)

      def initialize(site:)
        @site = site
      end

      def call
        Result.new(
          site_id: site.id,
          urn: site.urn,
          location_name: site.location_name,
        )
      end

    private

      attr_reader :site
    end
  end
end
