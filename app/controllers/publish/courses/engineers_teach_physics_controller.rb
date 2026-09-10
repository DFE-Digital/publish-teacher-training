# frozen_string_literal: true

module Publish
  module Courses
    class EngineersTeachPhysicsController < ApplicationController
      decorates_assigned :course
      include CourseBasicDetailConcern

      def edit
        @engineers_teach_physics_form = EngineersTeachPhysicsForm.new(course)
      end

      def update
        @engineers_teach_physics_form = EngineersTeachPhysicsForm.new(course, params: form_params)

        if form_params[:skip_languages_goto_confirmation].present?
          update_with_confirmation { save_and_redirect_to_details }
        elsif form_params[:subjects_ids]&.include?(modern_languages_id)
          if confirm_live_changes_if_required!(**engineers_live_changes_confirmation_args)
            # rendered interstitial
          else
            course.update(campaign_name: form_params[:campaign_name])
            redirect_to(
              modern_languages_publish_provider_recruitment_cycle_course_path(
                @course.provider_code,
                @course.recruitment_cycle_year,
                @course.course_code,
                course: { subjects_ids: form_params[:subjects_ids] },
              ),
            )
          end
        elsif form_params[:subjects_ids]&.include?(design_technology_id)
          if confirm_live_changes_if_required!(**engineers_live_changes_confirmation_args)
            # rendered interstitial
          else
            course.update(campaign_name: form_params[:campaign_name])
            redirect_to(
              design_technology_publish_provider_recruitment_cycle_course_path(
                @course.provider_code,
                @course.recruitment_cycle_year,
                @course.course_code,
                course: { subjects_ids: form_params[:subjects_ids] },
              ),
            )
          end
        else
          update_with_confirmation { save_and_redirect_to_details }
        end
      end

    private

      def update_with_confirmation
        if @engineers_teach_physics_form.invalid?
          @errors = @engineers_teach_physics_form.errors.messages
          render :edit
        elsif confirm_live_changes_if_required!(**engineers_live_changes_confirmation_args)
          # rendered interstitial
        elsif @engineers_teach_physics_form.save!
          yield
        else
          @errors = @engineers_teach_physics_form.errors.messages
          render :edit
        end
      end

      def save_and_redirect_to_details
        course_updated_message(section_key)
        course.update(name: course.generate_name)
        redirect_to(
          details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          ),
        )
      end

      def engineers_live_changes_confirmation_args
        {
          section_name: section_key,
          form: @engineers_teach_physics_form,
          form_param_key: :publish_engineers_teach_physics_form,
          cancel_path: details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code, recruitment_cycle.year, course.course_code
          ),
        }
      end

      def modern_languages_id
        SecondarySubject.modern_languages.id.to_s
      end

      def design_technology_id
        SecondarySubject.design_technology.id.to_s
      end

      def form_params
        params
          .expect(
            publish_engineers_teach_physics_form: [:campaign_name,
                                                   :skip_languages_goto_confirmation,
                                                   { subjects_ids: [] }],
          )
      end

      def section_key
        "Engineers Teach Physics"
      end
    end
  end
end
