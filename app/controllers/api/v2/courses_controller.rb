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
        response = sync_courses

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
        update_enrichment
        update_sites

        if @course.errors.empty? && @course.valid?
          render jsonapi: @course.reload
        else
          render jsonapi_errors: @course.errors, status: :unprocessable_entity
        end
      end

    private

      def sync_courses
        ManageCoursesAPIService::Request.sync_course_with_search_and_compare(
          @current_user.email,
          @provider.provider_code,
          @course.course_code
        )
      end

      def update_enrichment
        return unless enrichment_params.values.any?

        enrichment = first_draft_or_new_enrichment
        enrichment.assign_attributes(enrichment_params)
        enrichment.save
      end

      def update_sites
        return if site_ids.nil?

        @course.sites = @provider.sites.where(id: site_ids) if site_ids.any?
        # This validation is done at the controller level instead of the model.
        # This is because sites = [] is something that we can validate against,
        # but we can't actually revert easily from what I can tell because of the
        # remove_site! side effects that occur when it's called.
        @course.errors[:sites] << "^You must choose at least one location" if site_ids.empty?

        sync_courses if site_ids.any?
      end

      def first_draft_or_new_enrichment
        if @course.enrichments.draft.any?
          @course.enrichments.draft.first
        else
          @course.enrichments.new(status: 'draft')
        end
      end

      def build_provider
        @provider = Provider.find_by!(provider_code: params[:provider_code].upcase)
      end

      def build_course
        @course = @provider.courses.find_by!(course_code: params[:code].upcase)

        authorize @course
      end

      def enrichment_params
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

      def site_ids
        params.require(:course)[:sites_ids]
      end
    end
  end
end
