# frozen_string_literal: true

module Find
  module Courses
    module QualificationsSummaryComponent
      class View < ViewComponent::Base
        include ApplicationHelper
        include ::ViewHelper

        attr_reader :find_outcome

        def initialize(find_outcome)
          super
          @find_outcome = find_outcome
        end
      end
    end
  end
end
