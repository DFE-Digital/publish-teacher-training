# frozen_string_literal: true

module Find
  module Courses
    module ContactDetailsComponent
      class View < ViewComponent::Base
        attr_reader :course

        delegate :provider, to: :course

        def initialize(course)
          super
          @course = course
        end
      end
    end
  end
end
