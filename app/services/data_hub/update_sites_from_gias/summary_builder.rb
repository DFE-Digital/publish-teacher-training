module DataHub
  module UpdateSitesFromGias
    class SummaryBuilder
      ALL_FIELDS = %i[
        location_name
        address1
        address2
        address3
        town
        address4
        postcode
        latitude
        longitude
      ].freeze

      def initialize(results)
        @results = results
      end

      def short_summary
        field_counts = ALL_FIELDS.index_with { |field| updated_count(field) }

        {
          updated_total_count: updated_results.count,
        }.merge(field_counts)
      end

      def full_summary
        {
          site_updates: updated_results.map { |r| { id: r.site_id, changes: r.changes } },
        }
      end

    private

      attr_reader :results

      def updated_results
        @updated_results ||= results.select { |r| r.changes.present? }
      end

      def updated_count(field)
        updated_results.count { |r| r.changes.key?(field) }
      end
    end
  end
end
