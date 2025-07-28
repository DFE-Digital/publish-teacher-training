module DataHub
  module UpdateSitesFromGias
    class Executor
      BATCH_SIZE = 100

      attr_reader :recruitment_cycle, :updater_class, :diff_query, :results

      def initialize(recruitment_cycle:, updater_class: SiteUpdater, diff_query_class: SchoolsGiasDiffQuery)
        @recruitment_cycle = recruitment_cycle
        @updater_class = updater_class
        @diff_query = diff_query_class.new(recruitment_cycle:)
        @results = []
      end

      def execute
        process_summary = DataHub::UpdateSitesFromGiasProcessSummary.start!

        site_with_gias_difference do |site, gias_hash|
          result = updater_class.new(site:, gias_school: gias_hash).call
          results << result if result.changes.present?
        end

        summary_builder = SummaryBuilder.new(results)

        process_summary.finish!(
          short_summary: summary_builder.short_summary.merge(updater_class:),
          full_summary: summary_builder.full_summary,
        )

        process_summary
      rescue StandardError => e
        process_summary&.fail!(e)
        raise e
      end

    private

      def site_with_gias_difference
        diff_query.records_to_update.find_each(batch_size: BATCH_SIZE) do |site|
          gias_hash = build_gias_hash(site)
          yield(site, gias_hash)
        end
      end

      def build_gias_hash(site)
        {
          name: site.gias_name,
          address1: site.gias_address1,
          address2: site.gias_address2,
          address3: site.gias_address3,
          town: site.gias_town,
          county: site.gias_county,
          postcode: site.gias_postcode,
          latitude: site.gias_latitude,
          longitude: site.gias_longitude,
        }
      end
    end
  end
end
