# frozen_string_literal: true

module Find
  module Courses
    module TeacherDegreeApprenticeshipEntryRequirements
      class View < ViewComponent::Base
        attr_reader :course, :preview

        def initialize(course:, preview:)
          @course = course
          @preview = preview

          super
        end

        def render?
          course.teacher_degree_apprenticeship?
        end

        def any_a_levels_answered?
          !preview || course.any_a_levels?
        end
      end
    end
  end
end
