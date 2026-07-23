# frozen_string_literal: true

module CourseSchools
  # Chooses the school model for a provider's recruitment cycle.
  # Current and rollover cycles use legacy Site records; cycles after the remodel
  # use Provider::School records because Site and Provider::School UUIDs diverge
  # after rollover.
  class Identity
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

    def school_records_for(school_uuids:)
      school_uuids = normalize_school_uuids(school_uuids)
      validate_uuid_values!(school_uuids)

      records_by_uuid = school_records_by_uuid(school_uuids)
      validate_all_uuids_resolved!(school_uuids, records_by_uuid)
      ordered_records_for(school_uuids, records_by_uuid)
    end

  private

    attr_reader :provider, :course, :provider_identity

    def school_records_by_uuid(school_uuids)
      if after_schools_remodel_cycle?
        provider_schools_by_uuid(provider_school_uuids: school_uuids)
      else
        sites_by_uuid(site_uuids: school_uuids)
      end
    end

    def sites_by_uuid(site_uuids:)
      provider.sites.where(uuid: site_uuids).index_by { |site| site.uuid.to_s }
    end

    def provider_schools_by_uuid(provider_school_uuids:)
      provider.schools.where(uuid: provider_school_uuids).index_by { |school| school.uuid.to_s }
    end

    def ordered_records_for(school_uuids, records_by_uuid)
      school_uuids.map { |uuid| records_by_uuid.fetch(uuid) }
    end

    def normalize_school_uuids(school_uuids)
      Array(school_uuids).compact_blank.map(&:to_s).uniq
    end

    def require_course!
      return if course.present?

      raise ArgumentError, "CourseSchools::Identity requires a course for current_school_uuids"
    end

    def validate_uuid_values!(school_uuids)
      invalid_uuids = school_uuids.reject { |uuid| uuid?(uuid) }
      return if invalid_uuids.empty?

      raise ArgumentError, "School UUIDs must be valid UUIDs"
    end

    def validate_all_uuids_resolved!(school_uuids, records_by_uuid)
      unresolved_uuids = school_uuids - records_by_uuid.keys
      return if unresolved_uuids.empty?

      raise ArgumentError, "Could not resolve school UUIDs for provider #{provider.id}: #{unresolved_uuids.join(', ')}"
    end

    def uuid?(uuid)
      uuid.to_s.match?(UUID_PATTERN)
    end
  end
end
