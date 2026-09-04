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
      end
    end
  end
end
