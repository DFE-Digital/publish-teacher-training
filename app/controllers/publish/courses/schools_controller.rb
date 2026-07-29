# frozen_string_literal: true

module Publish
  module Courses
    class SchoolsController < ApplicationController
      include CourseBasicDetailConcern

      # The error path re-renders :new from #continue, so the view reads this
      # rather than an ivar only #new would set.
      helper_method :schools

      def continue
        params[:course][:school_uuids].compact_blank!
        super
      end

      def new
        authorize(@provider, :edit?)
        return unless schools.one?

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
          Publish::Schools::UpdateCourseSchoolsService.call_or_enqueue(course: @course, params: school_params)

          flash[:success] = if Array(@course_school_form.school_uuids).size > Publish::Schools::UpdateCourseSchoolsService::ENQUEUE_THRESHOLD
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
        if schools.many?
          redirect_to new_publish_provider_recruitment_cycle_courses_schools_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

    private

      # Every school the provider could attach, ordered by GIAS school name.
      def schools
        @schools ||= ::CourseSchools::Identity.new(provider: @provider).available_schools.to_a
      end

      def current_step
        :school
      end

      def error_keys
        [:sites]
      end

      def set_default_school
        params["course"] ||= {}
        params["course"]["school_uuids"] = [schools.first.uuid]
      end

      def school_params
        return { school_uuids: nil } if params[:publish_course_school_form][:school_uuids].all?(&:empty?)

        params.expect(publish_course_school_form: [:schools_validated, { school_uuids: [] }])
      end

      def build_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end

      def section_key
        "School".pluralize(Array(school_params[:school_uuids]).compact_blank.count)
      end
    end
  end
end
