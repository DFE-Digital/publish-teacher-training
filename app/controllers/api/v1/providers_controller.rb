module API
  module V1
    class ProvidersController < API::V1::ApplicationController
      include NextLinkHeader

      before_action :build_recruitment_cycle

      def index
        per_page = params[:per_page] || 100
        changed_since = params[:changed_since]
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute("LOCK provider, site IN SHARE UPDATE EXCLUSIVE MODE")
          @providers = @recruitment_cycle
                         .providers
                         .includes(:sites, :ucas_preferences, :contacts)
                         .changed_since(changed_since)
                         .limit(per_page)
        end

        set_next_link_header_using_changed_since_or_last_object(
          @providers.last,
          changed_since: changed_since,
          per_page: per_page,
          recruitment_year: params[:recruitment_year],
        )

        render json: @providers
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: "Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`" }.to_json, status: :bad_request
      end

    private

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end
    end
  end
end
