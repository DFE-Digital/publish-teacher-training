module DataHub
  module DiscardInvalidSchools
    class Executor
      BATCH_SIZE = 100

      attr_reader :no_urn_ids, :invalid_urns, :recruitment_cycle

      def initialize(year:, discarder_class: SiteDiscarder, site_filter: SiteFilter)
        @recruitment_cycle = RecruitmentCycle.find_by!(year: year)
        @discarder_class = discarder_class
        @site_filter = site_filter
        @no_urn_ids = []
        @invalid_urns = []
      end

      def execute
        process_summary = DataHub::DiscardInvalidSchoolsProcessSummary.start!

        discard_invalid_schools!

        summary_builder = SummaryBuilder.new(
          no_urn_ids: @no_urn_ids,
          invalid_urns: @invalid_urns,
        )

        process_summary.finish!(
          short_summary: summary_builder.short_summary,
          full_summary: summary_builder.full_summary,
        )
      rescue StandardError => e
        process_summary&.fail!(e)
        raise e
      end

    private

      def discard_invalid_schools!
        @site_filter.filter(recruitment_cycle:).find_each(batch_size: BATCH_SIZE) do |site|
          handle_discard_result(@discarder_class.new(site: site).call)
        end
      end

      def handle_discard_result(result)
        case result.reason
        when :no_urn
          @no_urn_ids << result.site_id
        when :invalid_urn
          @invalid_urns << { id: result.site_id, urn: result.urn }
        end
      end
    end
  end
end
