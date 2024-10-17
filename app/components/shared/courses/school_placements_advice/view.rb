# frozen_string_literal: true

module Shared
  module Courses
    module SchoolPlacementsAdvice
      class View < ViewComponent::Base
        attr_reader :course

        def initialize(course)
          super
          @course = course
          # @course_information_config = Configs::CourseInformation.new(course)
        end

        def render?
          # @course_information_config.show_placement_guidance?(:program_type)
        end
      end
    end
  end
end
