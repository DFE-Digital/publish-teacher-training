# frozen_string_literal: true

module DataHub
  module Sites
    module Deduplication
      # Encapsulates the result of running the deduplication logic so that it can
      # be formatted for reporting independently.
      class Outcome
        # @return [Array<DataHub::Sites::Deduplication::Deduplicator::GroupResult>]
        attr_reader :groups

        # @return [Boolean]
        attr_reader :dry_run

        # @param groups [Array<DataHub::Sites::Deduplication::Deduplicator::GroupResult>]
        # @param dry_run [Boolean]
        def initialize(groups:, dry_run:)
          @groups = groups
          @dry_run = dry_run
        end
      end
    end
  end
end
