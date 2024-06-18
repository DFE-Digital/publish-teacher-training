# frozen_string_literal: true

module Publish
  module Courses
    module ALevelRequirements
      class AreAnyAlevelsRequiredForThisCourseController < PublishController
        before_action { authorize provider }
        before_action :assign_course

        def new
          @wizard = ALevelsWizard.new(
            current_step:,
            provider: @provider,
            course: @course
          )
        end

        def create
          @wizard = ALevelsWizard.new(
            current_step:,
            provider: @provider,
            course: @course,
            step_params:
          )

          if @wizard.valid_step?
            redirect_to @wizard.next_step_path
          else
            render :new
          end
        end

        private

        def assign_course
          @course = CourseDecorator.new(provider.courses.find_by!(course_code: params[:course_code]))
        end

        def current_step
          :are_any_a_levels_required_for_this_course
        end

        def step_params
          params
        end
      end
    end
  end
end
