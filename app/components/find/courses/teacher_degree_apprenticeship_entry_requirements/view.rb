# frozen_string_literal: true

module Find
  module Courses
    module TeacherDegreeApprenticeshipEntryRequirements
      class View < ViewComponent::Base
        A_LEVEL_ATTRIBUTES = %i[a_level_subject_requirements accept_pending_a_level accept_a_level_equivalency additional_a_level_equivalencies].freeze
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
          !preview || A_LEVEL_ATTRIBUTES.any? { |attribute| course.public_send(attribute).present? }
        end
      end
    end
  end
end
