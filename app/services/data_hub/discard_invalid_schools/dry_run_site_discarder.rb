module DataHub
  module DiscardInvalidSchools
    class DryRunSiteDiscarder
      Result = Struct.new(:site_id, :urn, :reason, keyword_init: true)

      def initialize(site:)
        @site = site
      end

      def call
        Result.new(
          site_id: site.id,
          urn: site.urn,
          reason: site.urn.blank? ? :no_urn : :invalid_urn,
        )
      end

    private

      attr_reader :site
    end
  end
end
