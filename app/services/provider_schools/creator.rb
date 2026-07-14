# frozen_string_literal: true

module ProviderSchools
  # Writes a Provider::School row and owns site_code generation so the
  # new model never depends on legacy Site data. Locks the provider row
  # for the duration of the code-pick + insert so two concurrent adds
  # to the same provider can't hand out the same code. Idempotent under
  # RecordNotUnique (race with the backfill or another request).
  class Creator
    include ServicePattern

    def initialize(provider:, gias_school_id:, site_code: nil, uuid: nil)
      @provider = provider
      @gias_school_id = gias_school_id
      @site_code = site_code
      @uuid = uuid
    end

    def call
      @provider.with_lock do
        provider_school = existing_provider_school || @provider.schools.build(
          gias_school_id: @gias_school_id,
          site_code: target_site_code,
        )
        provider_school.uuid = @uuid if @uuid.present?
        provider_school.save! if provider_school.new_record? || provider_school.changed?
        provider_school
      end
    rescue ActiveRecord::RecordNotUnique
      existing_provider_school || raise
    end

  private

    def existing_provider_school
      provider_school_by_uuid || @provider.schools.find_by(gias_school_id: @gias_school_id, site_code: target_site_code)
    end

    def provider_school_by_uuid
      return if @uuid.blank?

      @provider.schools.find_by(uuid: @uuid)
    end

    def target_site_code
      @target_site_code ||= @site_code.presence || Schools::CodeGenerator.call(provider: @provider)
    end
  end
end
