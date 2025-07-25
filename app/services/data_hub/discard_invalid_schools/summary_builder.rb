module DataHub
  module DiscardInvalidSchools
    class SummaryBuilder
      def initialize(no_urn_ids:, invalid_urns:)
        @no_urn_ids = no_urn_ids
        @invalid_urns = invalid_urns
      end

      def short_summary
        {
          discarded_total_count: total_discarded,
          discarded_lack_urn: @no_urn_ids.size,
          discarded_invalid_gias_urn: @invalid_urns.size,
        }
      end

      def full_summary
        {
          discarded_ids_lack_urn: @no_urn_ids,
          discarded_invalid_urns: @invalid_urns,
        }
      end

    private

      def total_discarded
        @no_urn_ids.size + @invalid_urns.size
      end
    end
  end
end
