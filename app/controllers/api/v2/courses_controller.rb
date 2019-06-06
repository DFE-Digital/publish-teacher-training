module API
  module V2
    class CoursesController < API::V2::ApplicationController
      before_action :build_provider
      before_action :build_course, except: :index

      deserializable_resource :course,
                              only: %i[update],
                              class: API::V2::DeserializableCourse

      def index
        authorize @provider, :can_list_courses?
        authorize Course

        render jsonapi: @provider.courses, include: params[:include]
      end

      def show
        render jsonapi: @course, include: params[:include]
      end

      def sync_with_search_and_compare
        response = ManageCoursesAPIService::Request.sync_course_with_search_and_compare(
          @current_user.email,
          @provider.provider_code,
          @course.course_code
        )

        head response ? :ok : :internal_server_error
      end

      def publish
        if @course.publishable?
          @course.publish_sites
          @course.publish_enrichment(@current_user)

          response = ManageCoursesAPIService::Request.sync_course_with_search_and_compare(
            @current_user.email,
            @provider.provider_code,
            @course.course_code
          )

          head response ? :ok : :internal_server_error
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

      def update
        enrichment = if @course.enrichments.draft.any?
                       @course.enrichments.draft.first
                     else
                       @course.enrichments.new(status: 'draft')
                     end

        enrichment.assign_attributes(update_params)
        enrichment.save

        site_ids = params[:course][:sites_ids]
        @course.sites = @provider.sites.where(id: site_ids) if site_ids.present?
        @course.errors[:sites] << "^You must choose at least one location" if site_ids == []

        if @course.errors.empty? && @course.valid?
          render jsonapi: @course.reload
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

    private

      def build_provider
        @provider = Provider.find_by!(provider_code: params[:provider_code].upcase)
      end

      def build_course
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)

        authorize @course
      end

      def update_params
        params
          .require(:course)
          .except(:id, :type, :sites_ids, :sites_types)
          .permit(
            :about_course,
            :course_length,
            :fee_details,
            :fee_international,
            :fee_uk_eu,
            :financial_support,
            :how_school_placements_work,
            :interview_process,
            :other_requirements,
            :personal_qualities,
            :salary_details,
            :qualifications
          )
      end
    end
  end
end
