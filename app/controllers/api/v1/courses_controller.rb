module API
  module V1
    class CoursesController < API::V1::ApplicationController
      include NextLinkHeader
      include FirstItemFromNextPage

      before_action :build_recruitment_cycle

      def index
        per_page = (params[:per_page] || 100).to_i
        changed_since = params[:changed_since]

        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute("LOCK provider, provider_enrichment, site IN SHARE UPDATE EXCLUSIVE MODE")

          @courses = @recruitment_cycle
             .courses
             .includes(:provider,
                       :site_statuses,
                       :ucas_subjects,
                       site_statuses: %i[site course])
             .changed_since(changed_since)
             .not_new
             .limit(per_page)
        end

        set_next_link_header_using_changed_since_or_last_object(
          @courses.last,
          changed_since: changed_since,
          per_page: per_page,
          recruitment_year: params[:recruitment_year],
        )

        render json: @courses
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: "Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`" }.to_json, status: :bad_request
      end

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end
    end
  end
end
