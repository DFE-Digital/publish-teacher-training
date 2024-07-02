# frozen_string_literal: true

module Find
  module Courses
    module ALevelComponent
      class View < ViewComponent::Base
        attr_reader :course

        def initialize(course:)
          @course = course
          @a_level_row_component = ALevelRowComponent.new(course:)

          super
        end

        def a_levels_not_required?
          course.a_levels_requirements_answered? && course.a_level_requirements.blank?
        end

        def a_levels_not_required_content
          I18n.t('find.courses.a_level.a_levels_not_required')
        end

        def a_level_subject_requirements
          GroupedALevelSubjectRequirements.new(course).to_a_level_equivalency_array
        end

        def pending_a_level_summary_content
          if course.accept_pending_a_level?
            I18n.t('find.courses.a_level.consider_pending_a_level')
          else
            I18n.t('find.courses.a_level.not_consider_pending_a_level')
          end
        end

        def a_level_equivalency_summary_content
          if course.accept_a_level_equivalency?
            I18n.t('find.courses.a_level.consider_a_level_equivalency')
          else
            I18n.t('find.courses.a_level.not_consider_a_level_equivalency')
          end
        end
      end
    end
  end
end
