# frozen_string_literal: true

module Rollover
  module Schools
    class DualProviderCopier
      def initialize(legacy_copier:, new_copier:, uuid_syncer: ProviderSchools::SyncLegacySiteUuids)
        @legacy_copier = legacy_copier
        @new_copier = new_copier
        @uuid_syncer = uuid_syncer
      end

      def execute(provider:, new_provider:)
        legacy_result = legacy_copier.execute(provider:, new_provider:)
        new_copier.execute(provider:, new_provider:)
        uuid_syncer.call(provider: new_provider)

        legacy_result
      end

    private

      attr_reader :legacy_copier, :new_copier, :uuid_syncer
    end
  end
end
