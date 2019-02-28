module API
  module V1
    class CoursesController < ApplicationController
      include NextLinkHeader
      include FirstItemFromNextPage

      def index
        per_page = (params[:per_page] || 100).to_i
        changed_since = params[:changed_since]

        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.execute('LOCK provider, provider_enrichment, site IN SHARE UPDATE EXCLUSIVE MODE')
          # TODO: This will need to be scoped to opted-in providers.
          @courses = Course
          .providers_have_opted_in
                       .includes(:sites, :provider, :site_statuses, :subjects)
                       .changed_since(changed_since)
                       .limit(per_page)
        end

        set_next_link_header_using_changed_since_or_last_object(
          @courses.last,
          changed_since: changed_since,
          per_page: per_page
        )

        render json: @courses
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: 'Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`' }.to_json, status: 400
      end
    end
  end
end
