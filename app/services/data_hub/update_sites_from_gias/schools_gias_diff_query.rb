module DataHub
  module UpdateSitesFromGias
    class SchoolsGiasDiffQuery
      SQL_FIELDS = [
        %w[location_name name],
        %w[address1 address1],
        %w[address2 address2],
        %w[address3 address3],
        %w[town town],
        %w[address4 county],
        %w[postcode postcode],
        %w[latitude latitude],
        %w[longitude longitude],
      ].freeze

      FIELDS = %w[
        name address1 address2 address3 town county postcode latitude longitude
      ].freeze

      def self.gias_select_aliases
        FIELDS.map { |field| "gias_school.#{field} AS gias_#{field}" }
      end

      NORMALIZED_DIFFS = SQL_FIELDS.map do |site_field, gias_field|
        if %w[latitude longitude].include?(site_field)
          "site.#{site_field} IS DISTINCT FROM gias_school.#{gias_field}"
        elsif site_field == "postcode"
          "REPLACE(LOWER(TRIM(NULLIF(site.postcode, ''))), ' ', '') IS DISTINCT FROM REPLACE(LOWER(TRIM(NULLIF(gias_school.postcode, ''))), ' ', '')"
        else
          "LOWER(TRIM(NULLIF(site.#{site_field}, ''))) IS DISTINCT FROM LOWER(TRIM(NULLIF(gias_school.#{gias_field}, '')))"
        end
      end

      def initialize(recruitment_cycle:)
        @recruitment_cycle = recruitment_cycle
      end

      def records_to_update
        @recruitment_cycle
          .sites
          .school
          .kept
          .joins("INNER JOIN gias_school ON site.urn = gias_school.urn")
          .where(self.class::NORMALIZED_DIFFS.join(" OR "))
          .select("site.*, #{self.class.gias_select_aliases.join(', ')}")
      end
    end
  end
end
