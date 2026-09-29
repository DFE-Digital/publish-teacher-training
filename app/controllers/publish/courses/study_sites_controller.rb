# frozen_string_literal: true

module Publish
  module Courses
    class StudySitesController < ApplicationController
      include CourseBasicDetailConcern

      def edit
        @course_study_site_form = CourseStudySiteForm.new(@course)
      end

      def update
        @course_study_site_form = CourseStudySiteForm.new(@course, params: study_site_params)

        if @course_study_site_form.save!
          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          ), flash: { success: t("flash.updated", resource: "Study sites") }
        else
          render :edit
        end
      end

    private

      def study_site_params
        return { study_site_ids: nil } if params[:publish_course_study_site_form][:study_site_ids].all?(&:empty?)

        params.expect(publish_course_study_site_form: [{ study_site_ids: [] }])
      end
    end
  end
end
