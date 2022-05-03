module Publish
  module Courses
    class SitesController < PublishController
      before_action :build_course_params, only: %i[continue]

      include CourseBasicDetailConcern

      def continue
        super
      end

      def new
        authorize(@provider, :edit?)
        if @provider.sites.count == 1
          set_default_site
          redirect_to next_step
        end
      end

      def edit
        authorize(provider)

        @course_location_form = CourseLocationForm.new(@course)
      end

      def update
        authorize(provider)

        @course_location_form = CourseLocationForm.new(@course, params: location_params)
        if @course_location_form.save!
          course_details_success_message("course locations")

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      end

      def back
        authorize(@provider, :edit?)
        if @provider.sites.count > 1
          redirect_to new_publish_provider_recruitment_cycle_courses_locations_path(path_params)
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
        selected_site_ids = params.dig(:course, :site_statuses_attributes)
          .values
          .select { |field| field["selected"] == "1" }
          .map { |field| field["id"] }

        params["course"]["sites_ids"] = selected_site_ids
        params["course"].delete("site_statuses_attributes")
      end

      def location_params
        return { site_ids: nil } if params[:publish_course_location_form][:site_ids].all?(&:empty?)

        params.require(:publish_course_location_form).permit(site_ids: [])
      end

      def build_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end
    end
  end
end
