module API
  module V1
    class CoursesController < API::V1::ApplicationController
      include NextLinkHeader
      include FirstItemFromNextPage

      def index
        per_page = (params[:per_page] || 100).to_i
        changed_since = params[:changed_since]
        recruitment_year = params[:recruitment_year]

        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute('LOCK provider, provider_enrichment, site IN SHARE UPDATE EXCLUSIVE MODE')
          @courses = Course
                       .includes(:provider,
                                 :site_statuses,
                                 :subjects,
                                 site_statuses: [:site])
                       .changed_since(changed_since)
                       .by_recruitment_cycle(recruitment_year)
                       .limit(per_page)
        end

        set_next_link_header_using_changed_since_or_last_object(
          @courses.last,
          changed_since: changed_since,
          per_page: per_page,
          recruitment_year: recruitment_year
        )

        render json: @courses
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: 'Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`' }.to_json, status: :bad_request
      end
    end
  end
end
