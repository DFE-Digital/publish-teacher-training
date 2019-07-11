module API
  module V1
    class ProvidersController < API::V1::ApplicationController
      include NextLinkHeader

      before_action :build_recruitment_cycle

      # Potential edge case:
      #
      # It is possible for older updated_at values to written to the database
      # after this API has been queried for changes. This would mean that these
      # changes are missed when the client makes a subsequent request using the
      # next-link.
      #
      # Possible causes of older updated_at values:
      # - delay between c# calculating datetime.UtcNow and value being written
      #   to postgres
      # - clock drift between servers
      def index
        # only return 2019 courses until rollover is supported

        per_page = params[:per_page] || 100
        changed_since = params[:changed_since]
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute('LOCK provider, provider_enrichment, site IN SHARE UPDATE EXCLUSIVE MODE')
          @providers = Provider
                         .includes(:sites, :ucas_preferences, :contacts)
                         .changed_since(changed_since)
                         .limit(per_page)
                         .by_recruitment_cycle(@recruitment_cycle.year)
        end

        set_next_link_header_using_changed_since_or_last_object(
          @providers.last,
          changed_since: changed_since,
          per_page: per_page
        )

        render json: @providers
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: 'Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`' }.to_json, status: :bad_request
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_year]
        ) || RecruitmentCycle.current_recruitment_cycle
      end
    end
  end
end
