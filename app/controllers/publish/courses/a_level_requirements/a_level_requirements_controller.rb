# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class ALevelRequirementsController < ApplicationController
        before_action :assign_course, :verify_teacher_degree_apprenticeship_course

        def new
          @wizard = ALevelsWizard.new(
            current_step:,
            provider: @provider,
            course: @course,
            step_params:,
          )

          @wizard.valid_step? if params[:display_errors].present?
        end

        def create
          @wizard = ALevelsWizard.new(
            current_step:,
            provider: @provider,
            course: @course,
            step_params:,
          )

          if @wizard.save
            add_flash_message
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

      private

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

        def current_step
          controller_name.to_sym
        end
      end
    end
  end
end
