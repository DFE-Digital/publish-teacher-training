module DiscardInvalidSchools
  class Executor
    attr_reader :no_urn_ids, :invalid_urns

    BATCH_SIZE = 100

    def initialize(year:, discarder_class: SiteDiscarder)
      @year = year
      @summary = create_summary!
      @no_urn_ids = []
      @invalid_urns = []
      @discarder_class = discarder_class
    end

    def execute
      recruitment_cycle = RecruitmentCycle.find_by!(year: @year)

      SiteFilter.filter(recruitment_cycle:).find_each(batch_size: BATCH_SIZE) do |site|
        result = @discarder_class.new(site: site).call

        case result.reason
        when :no_urn
          @no_urn_ids << result.site_id
        when :invalid_urn
          @invalid_urns << { id: result.site_id, urn: result.urn }
        end
      end

      finalize_summary!
    rescue StandardError => e
      @summary.update!(
        status: "failed",
        finished_at: Time.zone.now,
        short_summary: { error: e.message, backtrace: e.backtrace },
      )
      raise e
    end

  private

    def create_summary!
      DataHub::DiscardInvalidSchoolsProcessSummary.create!(
        started_at: Time.zone.now,
        status: "started",
        short_summary: {},
        full_summary: {},
      )
    end

    def finalize_summary!
      summary_builder = SummaryBuilder.new(no_urn_ids:, invalid_urns:)

      @summary.update!(
        finished_at: Time.zone.now,
        status: "finished",
        short_summary: summary_builder.short_summary,
        full_summary: summary_builder.full_summary,
      )
    end
  end
end
