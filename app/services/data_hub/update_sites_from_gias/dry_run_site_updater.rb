module DataHub
  module UpdateSitesFromGias
    class DryRunSiteUpdater < SiteUpdater
      def call
        Result.new(site_id: site.id, changes: find_field_differences)
      end
    end
  end
end
