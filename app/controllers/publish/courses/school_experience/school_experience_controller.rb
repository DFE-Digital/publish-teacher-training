module Publish
  module Courses
    module SchoolExperience
      class SchoolExperienceController < ApplicationController
        before_action :assign_course
        before_action :assign_wizard

        helper_method def current_step
          @wizard.current_step
        end

        helper_method def current_step_name
          controller_name.to_sym
        end

        def new
          @wizard.current_step_valid? if params[:display_errors].present?
        end

        def create
          if @wizard.save_current_step
            add_flash_message if @wizard.next_step == :course_edit
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        def assign_wizard
          @wizard = SchoolExperienceWizard.new(
            current_step: current_step_name,
            current_step_params: step_params,
            state_store:,
          ).tap do |wizard|
            wizard.recruitment_cycle_year = params[:recruitment_cycle_year]
            wizard.provider_code = params[:provider_code]
            wizard.course_code = params[:course_code]
          end
        end

        def state_store
          SchoolExperienceWizard::StateStores::SchoolExperienceWizardStore.new(
            repository: SchoolExperienceWizard::Repositories::SchoolExperienceRepository.new(
              record: @course,
            ),
          )
        end

        def step_params
          params
        end

        def add_flash_message
          flash[:success] = t(".flash_success")
        end

        def assign_course
          @course ||= provider.courses.find_by!(course_code: params[:course_code])
          @course_decorator ||= CourseDecorator.new(@course) # rubocop:disable Naming/MemoizedInstanceVariableName
        end
      end
    end
  end
end
