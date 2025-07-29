module DataHub
  module RegisterSchoolImporter
    class SchoolCreator
      Result = Struct.new(:schools_added, :ignored_urns, :school_errors, keyword_init: true)

      def initialize(provider:, urns:, row_number:)
        @provider = provider
        @urns = urns
        @row_number = row_number
      end

      def call
        schools_added = []
        ignored_urns = []
        school_errors = []

        @urns.each do |urn|
          gias_school = find_gias_school(urn)
          if gias_school.nil?
            ignored_urns << build_ignored_hash(urn, ImportSummary::IGNORE_REASONS[:not_found_in_gias])
            next
          end

          site = find_site(urn)
          if site.persisted?
            ignored_urns << build_ignored_hash(urn, ImportSummary::IGNORE_REASONS[:school_already_exists])
            next
          end

          begin
            create!(site, gias_school)
            schools_added << { urn:, row: @row_number }
          rescue StandardError => e
            school_errors << { urn:, row: @row_number, error: e.message }
          end
        end

        Result.new(schools_added:, ignored_urns:, school_errors:)
      end

      def create!(site, gias_school)
        site.assign_attributes(gias_school.school_attributes)
        site.site_type = Site.site_types[:school]
        site.added_via = Site.added_via[:register_import]

        if gias_school.latitude.present? && gias_school.longitude.present?
          site.latitude  = gias_school.latitude
          site.longitude = gias_school.longitude
          site.skip_geocoding = true
        end

        site.save!
      end

    private

      def find_gias_school(urn)
        gias_schools_by_urn[urn]
      end

      def find_site(urn)
        sites_by_urn[urn] || @provider.sites.new(urn:)
      end

      def gias_schools_by_urn
        @gias_schools_by_urn ||= GiasSchool.open.where(urn: @urns).index_by(&:urn)
      end

      def sites_by_urn
        @sites_by_urn ||= @provider.sites.where(urn: @urns).index_by(&:urn)
      end

      def build_ignored_hash(urn, reason)
        { urn:, row: @row_number, reason: }
      end
    end
  end
end
