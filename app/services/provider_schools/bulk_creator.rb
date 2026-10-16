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
          next unsaved << gias_school unless gias_school.complete_address?

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

    def create(gias_school)
      ::ProviderSchools::Creator.call(provider:, gias_school_id: gias_school.id)
    end
  end
end
