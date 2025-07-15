module RegisterSchoolImporter
  class SchoolCreator
    Result = Struct.new(:schools_added, :ignored_urns)

    def initialize(provider:, urns:, row_number:)
      @provider = provider
      @urns = urns
      @row_number = row_number
    end

    def call
      schools_added = []
      ignored_urns = []

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

        create!(site, gias_school)
        schools_added << { urn:, row: @row_number }
      end

      Result.new(schools_added, ignored_urns)
    end

    def create!(site, gias_school)
      site.assign_attributes(gias_school.school_attributes)
      site.site_type = Site.site_types[:school]
      site.save!
    end

  private

    def find_gias_school(urn)
      GiasSchool.open.find_by(urn:)
    end

    def find_site(urn)
      @provider.sites.find_or_initialize_by(urn:)
    end

    def build_ignored_hash(urn, reason)
      { urn:, row: @row_number, reason: }
    end
  end
end
