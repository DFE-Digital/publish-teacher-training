# frozen_string_literal: true

module Publish
  module Courses
    module Schools
      # The bulk update review page: the courses the chosen scope matched, and
      # the ones it cannot touch, before anything is written.
      #
      # What was matched is worked out again when the change is confirmed rather
      # than carried over from the page. This was a GET, and a course can be
      # added, deleted or left with a single school between looking and
      # deciding - so the count reported is the set that was actually written.
      class BulkUpdateReviewsController < ApplicationController
        include Publish::Schools::BulkUpdateDraft

        before_action :require_a_chosen_scope

        def show
          authorize(provider)

          @matched = matched_courses
        end

        def update
          authorize(provider)

          matched = matched_courses
          change = [matched.ids, @draft.added_uuids, @draft.removed_uuids]

          # Taken out before the change is queued, so a second press of the
          # button meets the expiry redirect rather than applying it again.
          @draft.delete

          BulkUpdateCourseSchoolsJob.perform_async(*change)

          flash[:success] = t("publish.courses.schools.bulk_update.updated", count: matched.count)

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
          )
        end

      private

        # Reaching the review page without an answer, or with one that no longer
        # applies to the course, means going back and answering it.
        def require_a_chosen_scope
          return if @draft.nil? || scope.present?

          authorize(provider)
          redirect_to bulk_update_schools_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
            state_key: @draft.state_key,
          )
        end
      end
    end
  end
end
