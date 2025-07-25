module DataHub
  module DiscardInvalidSchools
    class SiteFilter
      def self.filter(recruitment_cycle:)
        recruitment_cycle
          .sites
          .school
          .kept
          .joins(:provider)
          .joins("LEFT OUTER JOIN gias_school ON site.urn = gias_school.urn")
          .where(provider: { recruitment_cycle_id: recruitment_cycle.id })
          .where("site.urn IS NULL OR gias_school.urn IS NULL OR gias_school.status_code = '3'")
          .where("TRIM(LOWER(site.location_name)) NOT SIMILAR TO '%main[ -]?site%'")
          .includes(:provider)
      end
    end
  end
end
