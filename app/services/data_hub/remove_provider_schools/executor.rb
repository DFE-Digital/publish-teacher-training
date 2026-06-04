module DataHub
  module RemoveProviderSchools
    class Executor
      BATCH_SIZE = 100

      attr_reader :provider, :recruitment_cycle

      def initialize(provider_code:, keep_urns:, year:, discarder_class: SiteDiscarder, site_filter: SiteFilter)
        @recruitment_cycle = RecruitmentCycle.find_by!(year:)
        @provider = @recruitment_cycle.providers.find_by!(provider_code:)
        @keep_urns = keep_urns.map(&:to_s)
        @discarder_class = discarder_class
        @site_filter = site_filter
        @removed = []
        @skipped_with_courses = []
      end

      def execute
        process_summary = DataHub::RemoveProviderSchoolsProcessSummary.start!

        remove_schools!

        summary_builder = SummaryBuilder.new(
          removed: @removed,
          skipped_with_courses: @skipped_with_courses,
          kept_present: kept_present,
          kept_missing: kept_missing,
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

      def remove_schools!
        @site_filter.filter(provider:, keep_urns: @keep_urns).find_each(batch_size: BATCH_SIZE) do |site|
          if site.has_no_course?
            result = @discarder_class.new(site:).call
            @removed << site_payload(result)
          else
            @skipped_with_courses << { id: site.id, urn: site.urn, location_name: site.location_name }
          end
        end
      end

      def site_payload(result)
        { id: result.site_id, urn: result.urn, location_name: result.location_name }
      end

      # Reconcile the keep list against what is actually on the account so support
      # can spot data issues (e.g. a URN they expected to keep that is missing).
      def present_keep_urns
        @present_keep_urns ||= provider.sites.where(urn: @keep_urns).pluck(:urn).uniq
      end

      def kept_present
        present_keep_urns
      end

      def kept_missing
        @keep_urns - present_keep_urns
      end
    end
  end
end
