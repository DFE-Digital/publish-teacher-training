# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class RemoveALevelSubjectConfirmationController < ALevelRequirementsController
        before_action :load_a_level_subject_requirement

        def destroy
          @wizard = ALevelsWizard.new(
            current_step:,
            provider: @provider,
            course: @course,
            step_params:
          )

          if @wizard.valid_step?
            @wizard.destroy
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        def step_params
          params[current_step] ||= ActionController::Parameters.new
          params[current_step].merge!(@a_level_subject_requirement.slice(:uuid, :subject, :other_subject))
          params
        end
      end
    end
  end
end
