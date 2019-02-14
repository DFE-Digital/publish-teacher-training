module Api
  module V1
    class CoursesController < V1ApplicationController
      include NextLinkHeader
      include FirstItemFromNextPage

      def index
        per_page = (params[:per_page] || 100).to_i
        changed_since = params[:changed_since]
        from_course_id = params[:from_course_id].to_i

        @courses = Course
          .includes(:sites, :provider, :site_statuses, :subjects)
          .changed_since(changed_since, from_course_id)

        next_course = first_item_from_next_page(@courses, per_page)

        @courses = @courses.limit(per_page)

        next_link_header("from_course_id", @courses.last, next_course, changed_since, per_page)

        render json: @courses
      rescue ActiveRecord::StatementInvalid
        render json: { status: 400, message: 'Invalid changed_since value, the format should be an ISO8601 UTC timestamp, for example: `2019-01-01T12:01:00Z`' }.to_json, status: 400
      end
    end
  end
end
