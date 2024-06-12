# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class AreAnyAlevelsRequiredForThisCourseController < PublishController
        before_action { authorize provider }

        def new
          @wizard = ALevelsWizard.new(
            current_step: :are_any_alevels_required_for_this_course,
            # changed me to actual parameters
            provider_code: '1', recruitment_cycle_year: '2025', course_code: 'ab',
          )
        end

        def create
          @wizard = ALevelsWizard.new(
            current_step: :are_any_alevels_required_for_this_course,
            # changed me to actual parameters
            provider_code: '1', recruitment_cycle_year: '2025', course_code: 'ab',
            step_params: params[:some_form_parameter_name]
          )

          if @wizard.valid_step?
            redirect @wizard.next_step_path
          else
            render :new
          end
        end
      end
    end
  end
end
