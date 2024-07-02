# frozen_string_literal: true

module Find
  module Courses
    module TeacherDegreeApprenticeshipEntryRequirements
      class View < ViewComponent::Base
        attr_reader :course

        def initialize(course:)
          @course = course

          super
        end

        def render?
          course.teacher_degree_apprenticeship?
        end
      end
    end
  end
end
