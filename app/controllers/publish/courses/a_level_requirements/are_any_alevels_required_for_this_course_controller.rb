# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class AreAnyAlevelsRequiredForThisCourseController < PublishController
        before_action { authorize provider }

        def new
          @wizard = ALevelsWizard.new(
            current_step: :are_any_alevels_required_for_this_course
          )
        end
      end
    end
  end
end
