# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class ALevelEquivalenciesController < ALevelRequirementsController
        def add_flash_message
          flash[:success] = t("course.#{@wizard.current_step.model_name.i18n_key}.success_message")
        end
      end
    end
  end
end
