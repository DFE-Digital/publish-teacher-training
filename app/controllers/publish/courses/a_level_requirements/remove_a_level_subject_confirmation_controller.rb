# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class RemoveALevelSubjectConfirmationController < ALevelRequirementsController
        before_action :load_a_level_subject_requirement

        def destroy
          if @wizard.save_current_step
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        def step_params
          params[current_step_name] ||= ActionController::Parameters.new
          params[current_step_name].merge!(params.permit!.to_h.slice(:uuid))
          params
        end

      private

        def state_store
          ALevelsWizard::StateStores::ALevel.new(
            repository: ALevelsWizard::Repositories::ALevelSubjectRemoval.new(
              record: @course,
              uuid: params[:uuid],
            ),
          )
        end
      end
    end
  end
end
