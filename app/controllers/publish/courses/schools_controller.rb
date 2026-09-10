# frozen_string_literal: true

module Publish
  module Courses
    class SchoolsController < ApplicationController
      include CourseBasicDetailConcern

      def edit
        @course_school_form = CourseSchoolForm.new(@course)
        @course_school_form.valid? if show_errors_on_publish?
      end

      def update
        @course_school_form = Publish::CourseSchoolForm.new(@course, params: school_params)

        if @course_school_form.valid?
          Publish::Schools::UpdateCourseSchoolsService.call_or_enqueue(
            course: @course,
            school_uuids: selected_school_uuids,
          )

          flash[:success] = if selected_school_uuids.size > Publish::Schools::UpdateCourseSchoolsService::ENQUEUE_THRESHOLD
                              I18n.t("success.enqueued_schools")
                            else
                              I18n.t("success.saved", value: section_key)
                            end

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      rescue Publish::Schools::UpdateCourseSchoolsService::UnresolvedProviderSchoolsError,
             Publish::Schools::UpdateCourseSiteStatusesService::UnresolvedSitesError => e
        Sentry.capture_exception(e)
        @course_school_form.errors.add(:school_uuids, :school_uuids_invalid)
        render :edit, status: :unprocessable_entity
      end

    private

      def school_params
        @school_params ||= params
          .expect(publish_course_school_form: [{ school_uuids: [] }])
          .tap do |permitted_params|
            permitted_params[:school_uuids] = nil if permitted_params[:school_uuids].all?(&:empty?)
          end
      end

      def selected_school_uuids
        @selected_school_uuids ||= Array(school_params[:school_uuids]).compact_blank.uniq
      end

      def build_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end

      def section_key
        "School".pluralize(selected_school_uuids.size)
      end
    end
  end
end
