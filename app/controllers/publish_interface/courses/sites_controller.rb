module PublishInterface
  module Courses
    class SitesController < PublishInterfaceController
      decorates_assigned :course
      before_action :build_course_params, only: %i[continue]

      include CourseBasicDetailConcern
      before_action :build_course, only: %i[edit update]
      before_action :build_provider_with_sites

      def continue
        super
      end

      def new
        authorize(@provider, :index?)
        if @provider.sites.count == 1
          set_default_site
          redirect_to next_step
        end
      end

      def edit; end

      def update
        @course.provider_code = @provider.provider_code
        selected_site_ids = params.dig(:course, :site_statuses_attributes)
          .values
          .select { |f| f["selected"] == "1" }
          .map { |f| f["id"] }

        @course.sites = @provider.sites.select { |site| selected_site_ids.include?(site.id) }

        if @course.save
          success_message = @course.is_running? ? "Course locations saved and published" : "Course locations saved"
          redirect_to provider_recruitment_cycle_course_path(params[:provider_code], params[:recruitment_cycle_year], params[:code]), flash: { success: success_message }
        else
          @errors = @course.errors.full_messages

          render :edit
        end
      end

      def back
        if @provider.sites.count > 1
          redirect_to new_provider_recruitment_cycle_courses_locations_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

    private

      def current_step
        :location
      end

      def error_keys
        [:sites]
      end

      def set_default_site
        params["course"] ||= {}
        params["course"]["sites_ids"] = [@provider.sites.first.id]
      end

      def build_course_params
        selected_site_ids = params["sites"]

        params["course"]["sites"] = selected_site_ids
        params.delete("sites")
      end

      def build_provider_with_sites
        @provider = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year])
                      .providers
                      .find_by(provider_code: params[:provider_code])
      end

      def build_course
        @provider_code = params[:provider_code]
        @course = Course
          .includes(:sites)
          .includes(provider: [:sites])
          .where(recruitment_cycle_year: params[:recruitment_cycle_year])
          .where(provider_code: @provider_code)
          .find(params[:code])
          .first
      end
    end
  end
end
