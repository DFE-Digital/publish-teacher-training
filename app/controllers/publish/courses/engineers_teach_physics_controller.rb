module Publish
  module Courses
    class EngineersTeachPhysicsController < PublishController
      decorates_assigned :course
      before_action :build_course_params, only: [:continue]
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_physics_subject?

        redirect_to next_step
      end

      def edit; end

      def update; end

      def back
        authorize(@provider, :edit?)
        if has_physics_subject?
          redirect_to new_publish_provider_recruitment_cycle_courses_engineers_teach_physics_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

      def continue
        super
      end

    private

      def build_course_params
        params[:course][:engineers_teach_physics_query] = params[:engineers_teach_physics_query]
      end

      def has_physics_subject?
        @course.name.split.first == "Physics"
      end

      def current_step
        :engineers_teach_physics
      end

      def error_keys
        [:engineers_teach_physics_query]
      end
    end
  end
end
