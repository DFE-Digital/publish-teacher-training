# frozen_string_literal: true

module Find
  module Courses
    module ALevelComponent
      class GroupedALevelSubjectRequirements
        attr_reader :course, :a_level_subject_requirements

        def initialize(course)
          @course = course
          @a_level_subject_requirements = Array(course.a_level_subject_requirements)
        end

        def to_a_level_equivalency_array
          grouped_a_level_subject_requirements.map do |a_level_subject_requirement, count|
            component = ALevelSubjectRequirementRowComponent.new(a_level_subject_requirement)

            if count > 1
              component.add_equivalency_suffix(course:, row_value: component.plural_row_value(count:))
            else
              component.add_equivalency_suffix(course:, row_value: component.row_value)
            end
          end
        end

        private

        def grouped_a_level_subject_requirements
          @a_level_subject_requirements.group_by { |req| req.except('uuid') }.transform_values(&:count)
        end
      end
    end
  end
end
