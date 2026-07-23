# frozen_string_literal: true

module CourseSchools
  class Identity
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
      if after_schools_remodel_cycle?
        course.schools.includes(:provider_school).map { |course_school| course_school.provider_school.uuid.to_s }
      else
        course.sites.map { |site| site.uuid.to_s }
      end
    end

    def school_records_for(school_uuids:)
      ordered_records_for(school_uuids, school_records_by_uuid(school_uuids))
    end

    def provider_schools_for(school_uuids:)
      school_uuids = normalize_uuids(school_uuids)

      if after_schools_remodel_cycle?
        ordered_records_for(school_uuids, provider_schools_by_uuid(school_uuids))
      else
        legacy_site_uuids = school_records_for(school_uuids:).select { |school| school.is_a?(Site) }.map(&:uuid)
        Publish::Schools::ProviderSchoolResolver.call(provider:, school_uuids: legacy_site_uuids)
      end
    end

  private

    attr_reader :provider, :course, :provider_identity

    def school_records_by_uuid(school_uuids)
      school_uuids = normalize_uuids(school_uuids)

      if after_schools_remodel_cycle?
        provider_schools_by_uuid(school_uuids)
      elsif school_uuids.all? { |uuid| uuid?(uuid) }
        provider.sites.where(uuid: school_uuids).index_by { |site| site.uuid.to_s }
      else
        provider.sites.where(id: school_uuids).index_by { |site| site.id.to_s }
      end
    end

    def provider_schools_by_uuid(school_uuids)
      provider.schools.where(uuid: normalize_uuids(school_uuids)).index_by { |school| school.uuid.to_s }
    end

    def ordered_records_for(school_uuids, records_by_uuid)
      normalize_uuids(school_uuids).filter_map { |uuid| records_by_uuid[uuid] }
    end

    def normalize_uuids(school_uuids)
      Array(school_uuids).compact_blank.map(&:to_s)
    end

    def uuid?(identifier)
      identifier.to_s.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
    end
  end
end
