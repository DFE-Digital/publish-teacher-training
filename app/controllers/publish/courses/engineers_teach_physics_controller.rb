# frozen_string_literal: true

module Publish
  module Courses
    class EngineersTeachPhysicsController < PublishController
      decorates_assigned :course
      include CourseBasicDetailConcern

      def new
        authorize(@provider, :can_create_course?)
        return if has_physics_subject?

        if go_to_confirmation_params && modern_languages_present?
          redirect_to new_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
          return
        end
        redirect_to next_step
      end

      def edit
        @engineers_teach_physics_form = EngineersTeachPhysicsForm.new(course)
      end

      def update
        @engineers_teach_physics_form = EngineersTeachPhysicsForm.new(course, params: form_params)
        if form_params[:skip_languages_goto_confirmation].present?

          if @engineers_teach_physics_form.save!
            course_updated_message(section_key)

            course.update(name: course.generate_name)
            redirect_to(
              details_publish_provider_recruitment_cycle_course_path(
                provider.provider_code,
                recruitment_cycle.year,
                course.course_code
              )
            )
          else
            render :edit
          end

        elsif form_params[:subjects_ids]&.include?(modern_languages_id)
          course.update(campaign_name: form_params[:campaign_name])
          redirect_to(
            modern_languages_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code,
              course: { subjects_ids: form_params[:subjects_ids] }
            )
          )
        elsif @engineers_teach_physics_form.save!
          course_updated_message(section_key)
          course.update(name: course.generate_name)

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )
        else
          @errors = @engineers_teach_physics_form.errors.messages
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

      def continue
        authorize(@provider, :can_create_course?)
        @errors = { campaign_name: ['Select if this course is part of the Engineers teach physics programme'] } if params[:course][:campaign_name].blank?

        if @errors.present?
          render :new
        elsif params[:skip_languages_goto_confirmation].present?
          redirect_to confirmation_publish_provider_recruitment_cycle_courses_path(path_params)
        elsif modern_languages_present?
          redirect_to new_publish_provider_recruitment_cycle_courses_modern_languages_path(path_params)
        else
          redirect_to next_step
        end
      end

      private

      def modern_languages_present?
        params[:course][:subjects_ids]&.include?(modern_languages_id)
      end

      def modern_languages_id
        SecondarySubject.modern_languages.id.to_s
      end

      def has_physics_subject?
        @course.master_subject_id == SecondarySubject.physics.id
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
            :campaign_name,
            :skip_languages_goto_confirmation,
            subjects_ids: []
          )
      end

      def section_key
        'Engineers Teach Physics'
      end
    end
  end
end
