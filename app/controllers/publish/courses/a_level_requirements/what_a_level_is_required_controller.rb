# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class WhatALevelIsRequiredController < ALevelRequirementsController
        before_action :load_a_level_subject_requirement
        after_action :set_flash_message, only: :step_params

        def step_params
          params[current_step] = ActionController::Parameters.new(@a_level_subject_requirement) if @a_level_subject_requirement.present?
          params
        end

        private

        def load_a_level_subject_requirement
          return if params[:uuid].blank?

          @a_level_subject_requirement = @course.find_a_level_subject_requirement!(params[:uuid])
        end

        def add_flash_message
          flash[:success] = t("course.#{@wizard.current_step.model_name.i18n_key}.success_message")
        end
      end
    end
  end
end
