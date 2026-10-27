# frozen_string_literal: true

module Publish
  module Courses
    # Edits a saved course through CourseWizard (see CourseWizard::Edit). The
    # entry point (new) seeds the edit under a new state_key. Each step then
    # shows only the questions that need an answer, and the last one saves the
    # edit and returns to the course page. An edit of a published course asks
    # the user to confirm first (the confirm_changes step).
    #
    # Behind the course_edit_wizard setting. A funding type edit is only for
    # draft or rolled over courses.
    class EditWizardsController < ApplicationController
      CACHE_EXPIRY = 24.hours

      before_action :require_course_edit_wizard
      before_action :set_wizard
      before_action -> { authorize(provider, :update?) }
      before_action :require_active_edit, except: :new
      before_action :authorize_funding_type

      helper_method def current_step
        @wizard.current_step
      end

      helper_method def current_step_name
        params[:step].to_sym
      end

      def new
        step = @wizard.edit.start(entry: params[:unit], caller: course_page_path)
        return redirect_to course_page_path unless step

        redirect_to @wizard.resolve_step_path(step)
      end

      def show
        redirect_to_entry_step unless @wizard.edit.accessible?(current_step_name)
      end

      def update
        return redirect_to_entry_step unless @wizard.edit.accessible?(current_step_name)

        if @wizard.save_current_step
          @wizard.track_review_step
          @wizard.clear_off_path_answers
          next_step = @wizard.next_step
          return commit if next_step == :courses_index

          redirect_to @wizard.resolve_step_path(next_step)
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def require_course_edit_wizard
        raise ActionController::RoutingError, "Not Found" unless FeatureService.enabled?(:course_edit_wizard)
      end

      # The edit was saved, expired, or belongs to another course. The course
      # page shows the saved values.
      def require_active_edit
        return if @wizard.edit.active?

        flash[:info] = t("publish.courses.edit_wizards.ended")
        redirect_to course_page_path
      end

      # Only a visa edit leaves the funding type alone. Any other edit gets
      # the funding type check.
      def authorize_funding_type
        authorize(course, :can_update_funding_type?) unless edit_unit == :visa
      end

      def edit_unit
        action_name == "new" ? CourseWizard::Edit.unit_for(params[:unit]) : @wizard.edit.unit
      end

      def commit
        unit = @wizard.edit.unit
        caller_url = @wizard.edit.caller_url
        result = @wizard.edit.commit!

        case result[:status]
        when :committed
          flash[:success] = t(".committed.#{unit}")
        when :stale
          flash[:warning] = t(".stale")
        when :failed
          flash[:warning] = { "title" => t(".failed"), "body" => ERB::Util.html_escape(result[:errors].to_sentence) }
        end

        redirect_to caller_url
      end

      def redirect_to_entry_step
        redirect_to @wizard.resolve_step_path(@wizard.edit.entry)
      end

      def course
        @course ||= provider.courses.find_by!(course_code: params[:code])
      end

      # The entry point (new) starts the edit under a new state_key
      def set_wizard
        state_key = action_name == "new" ? SecureRandom.uuid : params[:state_key]
        repository = CourseWizard::Repositories::CourseEdit.new(
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          state_key:,
          expires_in: CACHE_EXPIRY,
        )

        @wizard = CourseWizard.new(
          current_step: action_name == "new" ? nil : current_step_name,
          current_step_params: action_name == "new" ? {} : params,
          state_store: CourseWizard::StateStores::CourseWizardStore.new(repository:),
        ).tap do |wizard|
          wizard.recruitment_cycle_year = provider.recruitment_cycle_year
          wizard.provider_code = provider.provider_code
          wizard.state_key = state_key
          wizard.record = course
        end
      end

      def course_page_path
        details_publish_provider_recruitment_cycle_course_path(
          provider.provider_code,
          provider.recruitment_cycle_year,
          course.course_code,
        )
      end
    end
  end
end
