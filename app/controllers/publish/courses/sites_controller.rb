# frozen_string_literal: true

module Publish
  module Courses
    class SitesController < PublishController
      include CourseBasicDetailConcern

      def continue
        params[:course][:sites_ids].compact_blank!
        super
      end

      def new
        authorize(@provider, :edit?)
        return unless @provider.sites.count == 1

        set_default_site
        redirect_to next_step
      end

      def edit
        authorize(provider)

        @course_location_form = CourseLocationForm.new(@course)
        @course_location_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @course_location_form = CourseLocationForm.new(@course, params: location_params)
        if @course_location_form.save!
          course_updated_message(section_key)

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )
        else
          render :edit
        end
      end

      def back
        authorize(@provider, :edit?)
        if @provider.sites.count > 1
          redirect_to new_publish_provider_recruitment_cycle_courses_schools_path(path_params)
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
        params['course'] ||= {}
        params['course']['sites_ids'] = [@provider.sites.first.id]
      end

      def location_params
        return { site_ids: nil } if params[:publish_course_location_form][:site_ids].all?(&:empty?)

        params.require(:publish_course_location_form).permit(site_ids: [])
      end

      def build_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end

      def section_key
        'Location'.pluralize(location_params[:site_ids].compact_blank.count)
      end
    end
  end
end
