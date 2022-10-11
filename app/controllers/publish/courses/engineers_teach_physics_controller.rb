module Publish
  module Courses
    class EngineersTeachPhysicsController < PublishController
      decorates_assigned :course
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_physics_subject?

        redirect_to next_step
      end

      def edit
        authorize(@provider)
        @engineers_teach_physics_form = EngineersTeachPhysicsForm.new(course)
       end

      def update
        authorize(@provider)
        @engineers_teach_physics_form = EngineersTeachPhysicsForm.new(course, params: form_params)

        if @engineers_teach_physics_form.save!
          course.update(name: course.generate_name)

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      end

      def back
        authorize(@provider, :edit?)
        if has_physics_subject?
          redirect_to new_publish_provider_recruitment_cycle_courses_engineers_teach_physics_path(path_params)
        else
          redirect_to @back_link_path
        end
      end

    private

      def has_physics_subject?
        @course.master_subject_id == 29
      end

      def current_step
        :engineers_teach_physics
      end

      def error_keys
        [:campaign_name]
      end

      def form_params
        params
          .require(:publish_engineers_teach_physics_form)
          .permit(
            EngineersTeachPhysicsForm::FIELDS,
          )
      end
    end
  end
end
