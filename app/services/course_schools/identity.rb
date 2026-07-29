# frozen_string_literal: true

module CourseSchools
  # Read model for the course school pickers. Always returns Provider::School
  # records, so the list can be filtered by the education phase held on
  # gias_school.
  #
  # Only the write path still cares about the recruitment cycle, via
  # legacy_site_writes?: attaching a school keeps a legacy SiteStatus in step
  # until the Settings.schools_remodel_cycle_year cutover.
  class Identity
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

    delegate :count, to: :available_schools, prefix: true

    # Resolving submitted uuids is total: a school removed by a colleague
    # between render and submit, a tampered form or a stale wizard session all
    # arrive here, and none of them should 500. Callers decide what an
    # unresolved uuid means for them.
    Resolution = Struct.new(:records, :unresolved_uuids, keyword_init: true) do
      def all_resolved? = unresolved_uuids.empty?
    end

    def initialize(provider:, course: nil)
      @provider = provider
      @course = course
    end

    # legacy_site is preloaded for the "newly added" rollover tag, which reads
    # added_via off the paired Site. One extra query beats one per checkbox.
    def available_schools
      provider.schools.joins(:gias_school).includes(:gias_school, :legacy_site).order("gias_school.name")
    end

    def current_school_uuids
      require_course!

      attached_provider_schools.map { |provider_school| provider_school.uuid.to_s }
    end

    def school_records_for(school_uuids:)
      school_uuids = normalize_school_uuids(school_uuids)
      records_by_uuid = provider_schools_by_uuid(school_uuids)

      Resolution.new(
        records: school_uuids.filter_map { |uuid| records_by_uuid[uuid] },
        unresolved_uuids: school_uuids - records_by_uuid.keys,
      )
    end

    # Whether this cycle still keeps legacy Site and SiteStatus rows in step
    # with the new model. Purely a write-path question now that reads always
    # use Provider::School.
    def legacy_site_writes?
      !provider.recruitment_cycle.after?(Settings.schools_remodel_cycle_year)
    end

  private

    attr_reader :provider, :course

    # Two sources, deliberately unioned:
    #
    #   1. course.schools — the new model, canonical from the cutover.
    #   2. provider_schools whose uuid matches an attached legacy site, for the
    #      courses the schools backfill skipped. Without this the picker would
    #      render those attachments unticked and the next save would detach
    #      them. DataHub::SchoolsRemodelPreflight::Report counts them.
    #
    # A legacy attachment with no Provider::School is left out on purpose: the
    # picker cannot render it, so treating it as attached would make the write
    # path try to detach something it cannot address.
    def attached_provider_schools
      @attached_provider_schools ||= begin
        from_new_model = course.schools.includes(provider_school: :gias_school).map(&:provider_school)
        (from_new_model + attached_provider_schools_from_legacy_sites(from_new_model)).uniq
      end
    end

    def attached_provider_schools_from_legacy_sites(known)
      # After rollover Rollover::Schools::ProviderCopier mints fresh uuids, so
      # site.uuid and provider_school.uuid diverge and this map is wrong.
      return [] unless legacy_site_writes?

      unmatched_uuids = course.sites.map { |site| site.uuid.to_s } - known.map { |school| school.uuid.to_s }
      return [] if unmatched_uuids.empty?

      provider.schools.includes(:gias_school).where(uuid: unmatched_uuids).to_a
    end

    def provider_schools_by_uuid(school_uuids)
      resolvable = school_uuids.select { |uuid| uuid?(uuid) }
      return {} if resolvable.empty?

      provider.schools.includes(:gias_school).where(uuid: resolvable).index_by { |school| school.uuid.to_s }
    end

    def normalize_school_uuids(school_uuids)
      Array(school_uuids).compact_blank.map(&:to_s).uniq
    end

    def require_course!
      return if course.present?

      raise ArgumentError, "CourseSchools::Identity requires a course for current_school_uuids"
    end

    def uuid?(uuid)
      uuid.to_s.match?(UUID_PATTERN)
    end
  end
end
