# frozen_string_literal: true

module Publish
  module Courses
    # Edits a saved course's funding type or visa sponsorship through the
    # edit journey of CourseWizard: a change from check answers that ends on
    # the course page. The entry point (new) seeds the answers from the
    # course under a new state_key and opens the question its link names.
    # When the edit reaches the course page its answers are saved to the
    # course. An edit of a published course asks the user to confirm first.
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
      before_action :require_accessible_step, except: :new

      helper_method def current_step
        @wizard.current_step
      end

      helper_method def current_step_name
        params[:step].to_sym
      end

      helper_method def course_page_path
        @wizard.resolve_step_path(:course_page)
      end

      def new
        @wizard.state_store.write(CourseWizard::Mapper.new.to_answers(course))
        step = @wizard.opening_step(params[:unit])
        return redirect_to(@wizard.change_path(step)) if step

        @wizard.clear_state
        redirect_to course_page_path
      end

      def show; end

      def update
        if @wizard.save_current_step
          return save_edit if @wizard.next_step == :course_page

          redirect_to @wizard.next_step_path
        else
          render :show, status: :unprocessable_entity
        end
      end

    private

      def require_course_edit_wizard
        raise ActionController::RoutingError, "Not Found" unless FeatureService.enabled?(:course_edit_wizard)
      end

      # Only a visa edit leaves the funding type alone. Any other edit gets
      # the funding type check, on every request, so changing the URL cannot
      # open a question the user may not edit.
      def authorize_funding_type
        authorize(course, :can_update_funding_type?) unless @wizard.unit == :visa
      end

      # The edit was saved, expired, or has no question left to ask. The
      # course page shows the saved values. The edit seeds every answer of the
      # course, so an edit without the first question's answer has ended, even
      # if a late request wrote one of its answers back.
      def require_active_edit
        return if @wizard.step_data_exists?(@wizard.root_step) && @wizard.question_steps.any?

        flash[:info] = t("publish.courses.edit_wizards.ended")
        redirect_to course_page_path
      end

      def require_accessible_step
        redirect_to @wizard.change_path(@wizard.question_steps.first) unless @wizard.accessible?(current_step_name)
      end

      # Saves the edit's answers to the course, and ends the edit
      def save_edit
        result = @wizard.execute_operation(operation_class: CourseWizard::Operations::UpdateCourse, step: @wizard.current_step)
        @wizard.clear_state

        if !result[:success]
          flash[:warning] = { "title" => t(".failed"), "body" => ERB::Util.html_escape(result[:errors].to_sentence) }
        elsif result[:changed]
          flash[:success] = t(".committed.#{@wizard.unit}")
        end

        redirect_to course_page_path
      end

      def course
        @course ||= provider.courses.find_by!(course_code: params[:code])
      end

      # The entry point (new) starts the edit under a new state_key
      def set_wizard
        state_key = action_name == "new" ? SecureRandom.uuid : params[:state_key]
        unit = CourseWizard.unit_for(params[:unit])
        repository = CourseWizard::Repositories::CourseEdit.new(
          provider_code: provider.provider_code,
          recruitment_cycle_year: provider.recruitment_cycle_year,
          course_code: course.course_code,
          unit:,
          state_key:,
          expires_in: CACHE_EXPIRY,
        )

        @wizard = CourseWizard.new(
          current_step: action_name == "new" ? nil : current_step_name,
          current_step_params: action_name == "new" ? {} : params,
          state_store: CourseWizard::StateStores::CourseWizardStore.new(repository:),
          journey: :edit,
        ).tap do |wizard|
          wizard.recruitment_cycle_year = provider.recruitment_cycle_year
          wizard.provider_code = provider.provider_code
          wizard.state_key = state_key
          wizard.record = course
          wizard.unit = unit
        end
      end
    end
  end
end
