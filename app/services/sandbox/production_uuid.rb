# frozen_string_literal: true

module Sandbox
  # Production's uuid for a new record, unless a record here already has it,
  # in which case it's reported and nil returned, so the database generates
  # one. Existing records keep theirs, which Apply sandbox may already hold.
  module ProductionUuid
    def self.keep(uuid, unless_used_by:, label:, report:)
      return if uuid.blank?
      return uuid unless unless_used_by.exists?(uuid:)

      report.uuid_clashes << "#{label}: uuid #{uuid} is already used here"
      nil
    end
  end
end
