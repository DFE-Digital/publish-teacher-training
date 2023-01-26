# frozen_string_literal: true

module Find
  module Courses
    module ApplyComponent
      class View < ViewComponent::Base
        attr_reader :course

        delegate :has_vacancies?, :provider, to: :course

        def initialize(course)
          super
          @course = course
        end
      end

      def apply_path
        return find_apply_path(provider_code: course.provider.provider_code, course_code: course.course_code) if controller.class.module_parent == Find

        apply_publish_provider_recruitment_cycle_course_path(provider_code: course.provider.provider_code, code: course.course_code, recruitment_cycle_year: provider.recruitment_cycle.year)
      end
    end
  end
end
