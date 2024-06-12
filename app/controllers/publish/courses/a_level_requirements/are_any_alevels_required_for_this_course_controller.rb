# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class AreAnyAlevelsRequiredForThisCourseController < PublishController
        before_action { authorize provider }

        def new; end
      end
    end
  end
end
