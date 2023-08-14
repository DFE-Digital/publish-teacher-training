# frozen_string_literal: true

module Publish
  module Courses
    class StudySitesController < PublishController
      include CourseBasicDetailConcern

      def continue
        params[:course][:study_sites_ids].compact_blank!
        super
      end

      def new
        authorize(@provider, :edit?)

        return if @provider.study_sites.any?
        redirect_to next_step
      end

      def edit
        authorize(provider)

        @course_study_site_form = CourseStudySiteForm.new(@course)
      end

      def update
        authorize(provider)

        @course_study_site_form = CourseStudySiteForm.new(@course, params: study_site_params)

        if @course_study_site_form.save!
          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          ), flash: { success: t('flash.updated', resource: 'Study sites') }
        else
          render :edit
        end
      end

      def back
        authorize(@provider, :edit?)
        redirect_to @provider.study_sites.many? ? new_publish_provider_recruitment_cycle_courses_study_sites_path(path_params) : @back_link_path
      end

      private

      def update_course_study_sites
        study_site_ids = params[:course][:study_sites]
        @study_sites ||= provider.study_sites.find(study_site_ids.compact_blank!)

        course.study_sites = @study_sites.select { |site| study_site_ids.include?(site.id.to_s) }
      end

      def current_step
        :study_site
      end

      def error_keys
        [:study_sites]
      end

      def study_site_params
        return { study_site_ids: nil } if params[:publish_course_study_site_form][:study_site_ids].all?(&:empty?)

        params.require(:publish_course_study_site_form).permit(study_site_ids: [])
      end
    end
  end
end
