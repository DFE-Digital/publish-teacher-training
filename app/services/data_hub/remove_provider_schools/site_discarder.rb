module DataHub
  module RemoveProviderSchools
    class SiteDiscarder
      Result = Struct.new(:site_id, :urn, :location_name, keyword_init: true)

      def initialize(site:)
        @site = site
      end

      def call
        site.transaction do
          site.update_columns(discarded_via_script: true)
          site.discard
        end

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
