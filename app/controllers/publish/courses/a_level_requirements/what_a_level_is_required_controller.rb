# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class WhatALevelIsRequiredController < ALevelRequirementsController
        before_action :load_a_level_subject_requirement, :verify_maximum_a_level_subject_requirements

        def step_params
          params[current_step] = ActionController::Parameters.new(@a_level_subject_requirement) if @a_level_subject_requirement.present?
          params
        end

        private

        def add_flash_message
          flash[:success] = t("course.#{@wizard.current_step.model_name.i18n_key}.success_message")
        end

        def verify_maximum_a_level_subject_requirements
          return unless maximum_a_level_subject_requirements? && no_uuid?

          redirect_to publish_provider_recruitment_cycle_course_a_levels_add_a_level_to_a_list_path(
            provider.provider_code,
            provider.recruitment_cycle_year,
            @course.course_code
          )
        end

        def maximum_a_level_subject_requirements?
          Array(@course.a_level_subject_requirements).size >= ALevelSteps::AddALevelToAList::MAXIMUM_NUMBER_OF_A_LEVEL_SUBJECTS
        end

        def no_uuid?
          params[:uuid].blank? && params.dig(current_step, :uuid).blank?
        end
      end
    end
  end
end
