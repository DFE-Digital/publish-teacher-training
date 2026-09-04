# frozen_string_literal: true

module Publish
  module Courses
    module Schools
      # The bulk update options page: having chosen schools on the attach page,
      # the provider says which of their courses the change is for.
      #
      # The change itself travels in a draft the URL's state key resolves, so
      # every page here is a GET that can be refreshed and gone back to. A state
      # key that no longer resolves - expired, already applied, or somebody
      # else's - lands back on the attach page rather than on a page with
      # nothing behind it.
      class BulkUpdatesController < ApplicationController
        decorates_assigned :course

        before_action :build_course
        before_action :load_draft

        def edit
          authorize(provider)

          @form = BulkUpdateScopeForm.new(course: @course, scope: @draft.scope)
        end

        def update
          authorize(provider)

          @form = BulkUpdateScopeForm.new(course: @course, **scope_params)
          return render(:edit, status: :unprocessable_entity) unless @form.valid?

          apply(@form.chosen_scope)
        rescue Publish::Schools::UpdateCourseSchoolsService::UnresolvedProviderSchoolsError,
               Publish::Schools::UpdateCourseSiteStatusesService::UnresolvedSitesError => e
          Sentry.capture_exception(e)
          render_unresolved_schools
        end

      private

        def scope_params
          params.fetch(:bulk_update_scope_form, {}).permit(:scope).to_h.symbolize_keys
        end

        # Only this course is the change the attach page used to make, so it is
        # written there and then. Anything wider is queued: a bulk update writes
        # school relationships and their legacy site statuses for every course
        # it matches, and the single course write is already queued above thirty
        # schools.
        def apply(scope)
          if scope.token == "only_this_course"
            update_this_course
          else
            update_courses(scope)
          end

          @draft.delete

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        end

        # A school can be taken off the provider's list while the provider is
        # deciding which courses to apply it to. The draft is left where it is
        # and they are put back in front of their own choices, with the same
        # error the attach page has always shown.
        def render_unresolved_schools
          recruitment_cycle
          @course_school_form = Publish::CourseSchoolForm.new(@course, params: { school_uuids: @draft.school_uuids })
          @course_school_form.errors.add(:school_uuids, :school_uuids_invalid)

          render "publish/courses/schools/edit", status: :unprocessable_entity
        end

        def update_this_course
          Publish::Schools::UpdateCourseSchoolsService.call_or_enqueue(
            course: @course,
            school_uuids: @draft.school_uuids,
          )

          flash[:success] = if @draft.school_uuids.size > Publish::Schools::UpdateCourseSchoolsService::ENQUEUE_THRESHOLD
                              t("success.enqueued_schools")
                            else
                              t("success.saved", value: "School".pluralize(@draft.school_uuids.size))
                            end
        end

        def update_courses(scope)
          course_ids = scope.relation.pluck(:id)

          BulkUpdateCourseSchoolsJob.perform_async(
            course_ids,
            @draft.added_uuids,
            @draft.removed_uuids,
          )

          flash[:success] = t(
            "publish.courses.schools.bulk_update.updated",
            count: course_ids.size,
          )
        end

        def build_course
          @course = provider.courses.find_by!(course_code: params[:code])
        end

        def load_draft
          @draft = Publish::Schools::BulkUpdate::Draft.find(course: @course, state_key: params[:state_key])
          return if @draft

          authorize(provider)
          flash[:warning] = t("publish.courses.schools.bulk_update.expired")
          redirect_to schools_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        end
      end
    end
  end
end
