# frozen_string_literal: true

require "dfe/wizard/steps_processor/base"

module Publish
  module Courses
    module ALevelRequirements
      class ALevelRequirementsController < ApplicationController
        before_action :assign_course, :verify_teacher_degree_apprenticeship_course
        before_action :assign_wizard

        helper_method def current_step
          @wizard.current_step
        end

        helper_method def current_step_name
          controller_name.to_sym
        end

        def new
          @wizard.valid_step? if params[:display_errors].present?
        end

        def create
          if @wizard.save_current_step
            add_flash_message
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

      private

        def assign_wizard
          state_store = StateStores::ALevelStore.new(
            repository: DfE::Wizard::Repository::Model.new(
              record: @course,
            ),
          )

          @wizard = ALevelsWizard.new(
            current_step: current_step_name,
            current_step_params: defined?(step_params) && step_params || params,
            state_store:,
          ).tap do |wizard|
            wizard.recruitment_cycle_year = params[:recruitment_cycle_year]
            wizard.provider_code = params[:provider_code]
            wizard.course_code = params[:course_code]
          end

          @wizard
        end

        def add_flash_message; end

        def verify_teacher_degree_apprenticeship_course
          redirect_to publish_provider_recruitment_cycle_courses_path(provider_code: provider.provider_code, recruitment_cycle_year: provider.recruitment_cycle_year) unless @course.teacher_degree_apprenticeship?
        end

        def load_a_level_subject_requirement
          return if params[:uuid].blank?

          @a_level_subject_requirement = @course.find_a_level_subject_requirement!(params[:uuid])
        end

        def assign_course
          @course = provider.courses.find_by!(course_code: params[:course_code])
          @course_decorator = CourseDecorator.new(@course)
        end
      end
    end
  end
end
