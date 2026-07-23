# frozen_string_literal: true

module CourseSchools
  # Chooses the school model for a provider's recruitment cycle.
  # Current and rollover cycles use legacy Site records; cycles after the remodel
  # use Provider::School records because Site and Provider::School UUIDs diverge
  # after rollover.
  class Identity
    LEGACY_SITE_ID_PATTERN = /\A\d+\z/
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

    delegate :after_schools_remodel_cycle?, to: :provider_identity
    delegate :count, to: :available_schools, prefix: true

    def initialize(provider:, course: nil)
      @provider = provider
      @course = course
      @provider_identity = ProviderSchools::Identity.new(provider:)
    end

    def available_schools
      provider_identity.ordered_school_scope.to_a
    end

    def current_school_uuids
      require_course!

      if after_schools_remodel_cycle?
        course.schools.includes(:provider_school).map { |course_school| course_school.provider_school.uuid.to_s }
      else
        course.sites.map { |site| site.uuid.to_s }
      end
    end

    def school_records_for(school_identifiers:)
      school_identifiers = normalize_school_identifiers(school_identifiers)
      records_by_identifier = school_records_by_identifier(school_identifiers)

      validate_all_identifiers_resolved!(school_identifiers, records_by_identifier)
      ordered_records_for(school_identifiers, records_by_identifier)
    end

  private

    attr_reader :provider, :course, :provider_identity

    def school_records_by_identifier(school_identifiers)
      if after_schools_remodel_cycle?
        validate_uuid_identifiers!(school_identifiers)
        provider_schools_by_uuid(school_identifiers)
      else
        legacy_sites_by_identifier(school_identifiers)
      end
    end

    def legacy_sites_by_identifier(school_identifiers)
      if uuid_identifiers?(school_identifiers)
        sites_by_uuid(site_uuids: school_identifiers)
      elsif legacy_site_id_identifiers?(school_identifiers)
        sites_by_id(site_ids: school_identifiers)
      else
        raise ArgumentError, "School identifiers must not mix legacy Site IDs and UUIDs"
      end
    end

    def sites_by_uuid(site_uuids:)
      provider.sites.where(uuid: site_uuids).index_by { |site| site.uuid.to_s }
    end

    def sites_by_id(site_ids:)
      provider.sites.where(id: site_ids).index_by { |site| site.id.to_s }
    end

    def provider_schools_by_uuid(provider_school_uuids)
      provider.schools.where(uuid: provider_school_uuids).index_by { |school| school.uuid.to_s }
    end

    def uuid_identifiers?(school_identifiers)
      school_identifiers.all? { |identifier| uuid?(identifier) }
    end

    def legacy_site_id_identifiers?(school_identifiers)
      school_identifiers.all? { |identifier| legacy_site_id?(identifier) }
    end

    def ordered_records_for(school_identifiers, records_by_identifier)
      school_identifiers.map { |identifier| records_by_identifier.fetch(identifier) }
    end

    def normalize_school_identifiers(school_identifiers)
      Array(school_identifiers).compact_blank.map(&:to_s).uniq
    end

    def require_course!
      return if course.present?

      raise ArgumentError, "CourseSchools::Identity requires a course for current_school_uuids"
    end

    def validate_uuid_identifiers!(school_identifiers)
      invalid_identifiers = school_identifiers.reject { |identifier| uuid?(identifier) }
      return if invalid_identifiers.empty?

      raise ArgumentError, "School identifiers must be Provider::School UUIDs after the schools remodel cycle"
    end

    def validate_all_identifiers_resolved!(school_identifiers, records_by_identifier)
      unresolved_identifiers = school_identifiers - records_by_identifier.keys
      return if unresolved_identifiers.empty?

      raise ArgumentError, "Could not resolve school identifiers for provider #{provider.id}: #{unresolved_identifiers.join(', ')}"
    end

    def uuid?(identifier)
      identifier.to_s.match?(UUID_PATTERN)
    end

    def legacy_site_id?(identifier)
      identifier.to_s.match?(LEGACY_SITE_ID_PATTERN)
    end
  end
end
