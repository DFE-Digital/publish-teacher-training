# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class WhatALevelIsRequiredController < PublishController
        before_action { authorize provider }
        before_action :assign_course

        def new
          @wizard = ALevelsWizard.new(
            current_step:,
            provider: @provider,
            course: @course
          )
        end

        private

        def assign_course
          @course = CourseDecorator.new(provider.courses.find_by!(course_code: params[:course_code]))
        end

        def current_step
          :what_a_level_is_required
        end
      end
    end
  end
end
