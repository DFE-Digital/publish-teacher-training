# frozen_string_literal: true

module ProviderSchools
  # Writes a Provider::School row and owns site_code generation so the
  # new model never depends on legacy Site data. Locks the provider row
  # for the duration of the code-pick + insert so two concurrent adds
  # to the same provider can't hand out the same code. Idempotent under
  # RecordNotUnique (race with the backfill or another request).
  class Creator
    include ServicePattern

    def initialize(provider:, gias_school_id:)
      @provider = provider
      @gias_school_id = gias_school_id
    end

    def call
      @provider.with_lock do
        @provider.schools.find_or_create_by!(gias_school_id: @gias_school_id) do |school|
          school.site_code = Schools::CodeGenerator.call(provider: @provider)
        end
      end
    rescue ActiveRecord::RecordNotUnique
      @provider.schools.find_by!(gias_school_id: @gias_school_id)
    end
  end
end
