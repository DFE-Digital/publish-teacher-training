# frozen_string_literal: true

module Publish
  module Schools
    # The bulk update pages all work from the same thing: a course, and the
    # change waiting to be applied to it, which the URL's state key resolves.
    #
    # A state key that no longer resolves - expired, already applied, or issued
    # for another course - lands back on the attach page rather than on a page
    # with nothing behind it. That is also what a refresh after confirming and a
    # bookmark from yesterday both hit.
    module BulkUpdateDraft
      extend ActiveSupport::Concern

      included do
        decorates_assigned :course
        helper_method :scope, :school_changes

        before_action :build_course
        before_action :load_draft
      end

    private

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

      def scope
        @scope ||= Publish::Schools::BulkUpdate::Scope.find(course: @course, token: @draft.scope)
      end

      # What the provider is adding and taking off, measured against the same
      # list they ticked and the schools the course held when they did.
      def school_changes
        @school_changes ||= Publish::Schools::SchoolChanges.new(
          schools: SchoolsList.for(@course.provider),
          submitted: @draft.school_uuids,
          baseline: @draft.baseline_uuids,
        )
      end

      def matched_courses
        @matched_courses ||= Publish::Schools::BulkUpdate::MatchedCourses.new(
          scope:,
          added_uuids: @draft.added_uuids,
          removed_uuids: @draft.removed_uuids,
        )
      end
    end
  end
end
