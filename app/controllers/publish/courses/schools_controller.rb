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
          # Capture current state BEFORE update
          previous_site_ids = @course.site_ids.sort
          # Capture new state AFTER update
          new_site_ids = Array(school_params[:site_ids])
            .compact_blank
            .map(&:to_i)
            .sort

          added_site_ids   = new_site_ids - previous_site_ids
          removed_site_ids = previous_site_ids - new_site_ids

          added_count   = added_site_ids.size
          removed_count = removed_site_ids.size

          # Update course schools (async if above threshold)
          Publish::Schools::UpdateCourseSchoolsService.call_or_enqueue(
            course: @course,
            params: school_params,
          )

          # Determine where to redirect based on whether user has finished updating schools or not
          finished = params[:publish_course_school_form][:finished_updating_schools]

          # If user has finished updating schools, show banner with counts of added/removed schools and redirect back to placement schools page
          if finished == "no"
            # Counts banner ONLY on schools page
            parts = []
            parts << "#{added_count} school#{'s' unless added_count == 1} added" if added_count.positive?
            parts << "#{removed_count} school#{'s' unless removed_count == 1} removed" if removed_count.positive?

            if parts.any?
              flash[:success] = {
                "title" => "Placement schools updated",
                "body" => parts.join(" and "),
              }
            end

            redirect_to schools_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )
          # else
          #   # Restore EXISTING behaviour for Basic details (no schools count included in banner (just schools updated message) - couldn't work out how to do this easily!)
          #   flash[:success] =
          #     if Array(@course_school_form.site_ids).size >
          #         Publish::Schools::UpdateCourseSchoolsService::ENQUEUE_THRESHOLD
          #       I18n.t("success.enqueued_schools")
          #     else
          #       I18n.t("success.saved", value: section_key)
          #     end

          #   redirect_to details_publish_provider_recruitment_cycle_course_path(
          #     provider.provider_code,
          #     recruitment_cycle.year,
          #     course.course_code,
          #   )
          # end

          else
            # redirect to bulk update schools page if user is not finished updating schools (i.e. they want to make further updates to other courses)
            redirect_to edit_bulk_schools_publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
              added_count: added_count,
              removed_count: removed_count,
              added_site_ids: added_site_ids,
              removed_site_ids: removed_site_ids,
            )
          end
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
        # return { site_ids: nil } if params[:publish_course_school_form][:site_ids].all?(&:empty?)

        params.expect(publish_course_school_form: [:schools_validated, { site_ids: [] }])
      end

      def build_course
        @course = provider.courses.find_by!(course_code: params[:code])
      end

      def section_key
        "School".pluralize(school_params[:site_ids].compact_blank.count)
      end
    end
  end
end
