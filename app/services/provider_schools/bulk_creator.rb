# frozen_string_literal: true

module ProviderSchools
  class BulkCreator
    include ServicePattern

    Result = Data.define(:saved, :unsaved)

    # legacy_site: false creates only the Provider::School. Support no longer
    # dual-writes to Site; Publish still does.
    def initialize(provider:, gias_schools:, legacy_site: true)
      @provider = provider
      @gias_schools = gias_schools
      @legacy_site = legacy_site
    end

    def call
      saved = []
      unsaved = []

      TouchSuppression.suppress do
        gias_schools.each do |gias_school|
          next unsaved << gias_school unless addable?(gias_school)

          ActiveRecord::Base.transaction do
            saved << create(gias_school)
          end
        rescue ActiveRecord::RecordInvalid => e
          Sentry.capture_exception(e)
          unsaved << gias_school
        end
      end

      ::ProviderSchools::TouchParents.call(provider:) if saved.any?

      Result.new(saved:, unsaved:)
    end

  private

    attr_reader :provider, :gias_schools, :legacy_site

    # The legacy Site validates its own address, so only check it here when
    # no Site is written.
    def addable?(gias_school)
      legacy_site || gias_school.complete_address?
    end

    def create(gias_school)
      return ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id) unless legacy_site

      create_with_legacy_site(gias_school)
    end

    # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    # TODO School data remodel removal - remove this legacy Site write when provider schools are created directly.
    def create_with_legacy_site(gias_school)
      legacy_site = provider.sites.build(gias_school.school_attributes)
      ::ProviderSchools::LegacySiteCreator.call(site: legacy_site)
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

      ::ProviderSchools::Creator.call(
        provider:,
        gias_school_id: gias_school.id,
        site_code: legacy_site.code,
        uuid: legacy_site.uuid,
      )
    end
  end
end
