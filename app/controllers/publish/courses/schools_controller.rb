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
        @course_school_form = CourseSchoolForm.new(@course, params: seeded_params)
        @course_school_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @course_school_form = Publish::CourseSchoolForm.new(@course, params: school_params)

        if @course_school_form.valid?
          return hand_over_to_bulk_update if schools_changed?

          save_schools
        else
          render :edit
        end
      rescue Publish::Schools::UpdateCourseSchoolsService::UnresolvedProviderSchoolsError,
             Publish::Schools::UpdateCourseSiteStatusesService::UnresolvedSitesError => e
        Sentry.capture_exception(e)
        @course_school_form.errors.add(:school_uuids, :school_uuids_invalid)
        render :edit, status: :unprocessable_entity
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

      # Nothing is written here any more unless the selection is the one the
      # course already has. What the provider ticked goes into a draft, and the
      # bulk update pages apply it once they have been told which courses it is
      # for - the same change may be for hundreds of them.
      def hand_over_to_bulk_update
        draft = Publish::Schools::BulkUpdate::Draft.create(
          course: @course,
          school_uuids: selected_school_uuids,
          baseline_uuids: @course_school_form.attached_school_uuids,
        )

        redirect_to bulk_update_schools_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          recruitment_cycle.year,
          course.course_code,
          state_key: draft.state_key,
        )
      end

      # Submitting the selection unchanged asks nothing of any other course, so
      # it stays where it has always been: saved, and back to the course.
      def save_schools
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
      end

      def schools_changed?
        selected_school_uuids.sort != @course_school_form.attached_school_uuids.sort
      end

      # Arriving back from the bulk update pages, the boxes show what the
      # provider chose rather than what the course holds - they have not saved
      # yet, and a list they have just worked through is not something to make
      # them tick again.
      def seeded_params
        draft = Publish::Schools::BulkUpdate::Draft.find(course: @course, state_key: params[:state_key])
        return {} if draft.nil?

        { school_uuids: draft.school_uuids }
      end

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
