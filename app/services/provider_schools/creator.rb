# frozen_string_literal: true

module ProviderSchools
  # Writes a Provider::School row and owns site_code generation. Locks the
  # provider row for the duration of the code-pick + insert so two concurrent
  # adds to the same provider can't hand out the same code. Idempotent: an
  # existing non-main row for the GIAS school is returned rather than a second
  # one being created, including under RecordNotUnique.
  class Creator
    include ServicePattern

    def initialize(provider:, gias_school_id:)
      @provider = provider
      @gias_school_id = gias_school_id
    end

    def call
      @provider.with_lock do
        existing_provider_school || @provider.schools.create!(
          gias_school_id: @gias_school_id,
          site_code: Schools::CodeGenerator.call(provider: @provider),
        )
      end
    rescue ActiveRecord::RecordNotUnique
      existing_provider_school || raise
    end

  private

    def existing_provider_school
      @provider.schools.where(gias_school_id: @gias_school_id)
               .where.not(site_code: Provider::School::MAIN_SITE_CODE)
               .first
    end
  end
end
