# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class WhatALevelIsRequiredController < ALevelRequirementsController
        before_action :load_a_level_subject_requirement

        def step_params
          params[current_step] = ActionController::Parameters.new(@a_level_subject_requirement) if @a_level_subject_requirement.present?
          params
        end

        private

        def add_flash_message
          flash[:success] = t("course.#{@wizard.current_step.model_name.i18n_key}.success_message")
        end
      end
    end
  end
end
