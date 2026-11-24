# frozen_string_literal: true

module Sandbox
  # What an import of a provider's courses did, as lists of labels.
  # Each course collects into its own report, merged into the run's
  # report only once the course has saved.
  class ImportReport
    FIELDS = %i[
      created
      updated
      skipped
      not_published
      schools_created
      schools_unlinked
      gias_stubs
      conflicts
      uuid_clashes
      missing_accredited_providers
      sandbox_only
    ].freeze

    attr_reader(*FIELDS)
    attr_writer :sandbox_only

    # Which provider the report is for, and whether the import created or
    # restored that provider (nil when it was already here).
    attr_accessor :provider_name, :provider_status

    def initialize
      FIELDS.each { |field| instance_variable_set(:"@#{field}", []) }
    end

    def merge!(other)
      FIELDS.each { |field| public_send(field).concat(other.public_send(field)) }
      missing_accredited_providers.uniq!
      self
    end
  end
end
