# frozen_string_literal: true

module Find
  module Courses
    module QualificationsSummaryComponent
      class View < ViewComponent::Base
        include ApplicationHelper
        include ::ViewHelper

        attr_reader :course
        delegate :find_outcome, to: :course
        alias_method :summary_text, :find_outcome

        def initialize(course:)
          super
          @course = course
        end
      end
    end
  end
end
