# frozen_string_literal: true

module Publish
  module Courses
    class SchoolsController < ApplicationController
      include CourseBasicDetailConcern

      def continue
        params[:course][:sites_ids].compact_blank!
        super
      end

      def new
        authorize(@provider, :edit?)
        return unless @provider.sites.count == 1

        set_default_school
        redirect_to next_step
      end

      def edit
        @course_school_form = CourseSchoolForm.new(@course)
        @course_school_form.valid? if show_errors_on_publish?
      end

      def update
        @course_school_form = Publish::CourseSchoolForm.new(@course, params: school_params)

        if @course_school_form.valid?
          update_course_schools

          flash[:success] = if selected_school_uuids_count > Publish::Schools::UpdateCourseSchoolsService::ENQUEUE_THRESHOLD
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
        :school
      end

      def error_keys
        [:sites]
      end

      def set_default_school
        params["course"] ||= {}
        params["course"]["sites_ids"] = [@provider.sites.first.id]
      end

      def school_params
        return { school_uuids: nil } if params[:publish_course_school_form][:school_uuids].all?(&:empty?)

        params.expect(publish_course_school_form: [:schools_validated, { school_uuids: [] }])
      end

      def build_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end

      def section_key
        "School".pluralize(selected_school_uuids_count)
      end

      # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
      # TODO School data remodel removal - remove the UpdateCourseSchoolsService call when SiteStatus is no longer dual-written.
      def update_course_schools
        if selected_school_uuids_count > Publish::Schools::UpdateCourseSchoolsService::ENQUEUE_THRESHOLD
          UpdateCourseSchoolsJob.perform_async(@course.id, school_params.to_h)
        else
          Publish::Schools::UpdateCourseSchoolsService.new(course: @course, params: school_params).call
          Publish::Schools::UpdateCourseProviderSchoolsService.call(course: @course, params: school_params)
        end
      end
      # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

      def selected_school_uuids_count
        Array(school_params[:school_uuids]).compact_blank.count
      end
    end
  end
end
