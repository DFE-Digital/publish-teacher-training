# frozen_string_literal: true

module ProviderSchools
  class BulkCreator
    include ServicePattern

    Result = Data.define(:saved, :unsaved)

    def initialize(provider:, gias_schools:)
      @provider = provider
      @gias_schools = gias_schools
    end

    def call
      saved = []
      unsaved = []

      TouchSuppression.suppress do
        gias_schools.each do |gias_school|
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

    attr_reader :provider, :gias_schools

    # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
    # TODO School data remodel removal - remove this legacy Site write when provider schools are created directly.
    def create(gias_school)
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
