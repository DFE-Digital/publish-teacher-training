# frozen_string_literal: true

module Publish
  module Courses
    # Edits a saved course through CourseWizard. The entry point (new)
    # seeds a changeset under a new state_key and starts a change journey
    # for one unit. Each step request then reads that changeset. The save of
    # the journey's last question commits the edit and returns to the
    # course page. An edit of a published course asks the user to confirm
    # first (the confirm_changes step), and commits when they do.
    #
    # Behind the course_edit_wizard setting. A funding type edit is only for
    # draft or rolled over courses.
    class EditWizardsController < ApplicationController
      CACHE_EXPIRY = 24.hours

      before_action :require_course_edit_wizard
      before_action :set_wizard, except: :new
      before_action :authorize_edit

      rescue_from DfE::Wizard::ChangesetExpired, DfE::Wizard::ChangesetMismatch, with: :edit_ended

      helper_method def current_step
        @wizard.current_step
      end

      helper_method def current_step_name
        params[:step].to_sym
      end

      def new
        wizard = build_wizard(state_key: SecureRandom.uuid)
        step = wizard.start_edit(unit: params[:unit].to_sym, caller: course_page_path)

        redirect_to wizard.resolve_step_path(step)
      rescue DfE::Wizard::NotCallable
        redirect_to course_page_path
      end

      def show
        redirect_to_current_unit unless @wizard.step_accessible?(current_step_name)
      end

      def update
        return redirect_to_current_unit unless @wizard.step_accessible?(current_step_name)

        unit = edit_unit
        if @wizard.save_current_step
          flash_commit_result(unit) if @wizard.commit_result
          redirect_to @wizard.next_step_path
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def require_course_edit_wizard
        raise ActionController::RoutingError, "Not Found" unless FeatureService.enabled?(:course_edit_wizard)
      end

      def authorize_edit
        authorize(provider, :update?)
        authorize(course, :can_update_funding_type?) if edit_unit == :funding_type
      end

      # The unit the edit started with: the entry point's unit param, then
      # the one the changeset keeps
      def edit_unit
        action_name == "new" ? params[:unit].to_sym : @wizard.changeset.edit_unit
      end

      def course
        @course ||= provider.courses.find_by!(course_code: params[:code])
      end

      def set_wizard
        @wizard = build_wizard(state_key: params[:state_key], step: current_step_name, step_params: params)
      end

      def build_wizard(state_key:, step: nil, step_params: {})
        repository = CourseWizard::Repositories::Course.new(
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          state_key:,
          expires_in: CACHE_EXPIRY,
        )

        CourseWizard.new(
          current_step: step,
          current_step_params: step_params,
          state_store: CourseWizard::StateStores::CourseWizardStore.new(repository:),
          record: course,
        ).tap do |wizard|
          wizard.recruitment_cycle_year = provider.recruitment_cycle_year
          wizard.provider_code = provider.provider_code
          wizard.state_key = state_key
        end
      end

      def redirect_to_current_unit
        redirect_to @wizard.resolve_step_path(@wizard.redirect_step)
      end

      def flash_commit_result(unit)
        result = @wizard.commit_result

        case result[:status]
        when :committed
          flash[:success] = t(".committed.#{unit}")
        when :stale
          flash[:warning] = t(".stale")
        when :failed
          flash[:warning] = { "title" => t(".failed"), "body" => ERB::Util.html_escape(result[:errors].to_sentence) }
        end
      end

      # The changeset is gone (the edit was saved, or it expired) or belongs
      # to another course. The course page shows the saved values.
      def edit_ended
        flash[:info] = t("publish.courses.edit_wizards.ended")
        redirect_to course_page_path
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
