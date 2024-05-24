# frozen_string_literal: true

module Publish
  module Courses
    class StudyModeController < PublishController
      include CourseBasicDetailConcern

      def continue
        authorize(@provider, :can_create_course?)

        if previous_tda_course_path?
          redirect_to appropriate_visa_new_path
        else
          super
        end
      end

      def edit
        authorize(provider)

        @course_study_mode_form = CourseStudyModeForm.new(@course)
      end

      def update
        authorize(provider)

        @course_study_mode_form = CourseStudyModeForm.new(@course, params: study_mode_params)

        if @course_study_mode_form.save!
          handle_redirect
        else
          render :edit
        end
      end

      private

      def study_mode_params
        return { study_mode: nil } if params[:publish_course_study_mode_form].blank?

        params.require(:publish_course_study_mode_form).permit(:previous_tda_course, study_mode: [])
      end

      def handle_redirect
        if previous_tda_course?
          redirect_to appropriate_visa_path
        else
          course_updated_message I18n.t('publish.providers.study_mode.form.study_pattern')
          redirect_to details_publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code
          )
        end
      end

      def previous_tda_course?
        params[:publish_course_study_mode_form][:previous_tda_course] == 'true'
      end

      def appropriate_visa_path
        if @course.student_visa?
          student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(provider_code: course.provider_code,
                                                                                  recruitment_cycle_year: course.recruitment_cycle_year,
                                                                                  course_code: course.course_code)
        else
          skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(provider_code: course.provider_code,
                                                                                         recruitment_cycle_year: course.recruitment_cycle_year,
                                                                                         course_code: course.course_code)
        end
      end

      def appropriate_visa_new_path
        if @course.student_visa?
          new_publish_provider_recruitment_cycle_courses_student_visa_sponsorship_path(path_params)
        else
          new_publish_provider_recruitment_cycle_courses_skilled_worker_visa_sponsorship_path(path_params)
        end
      end

      def current_step
        :full_or_part_time
      end

      def errors
        params.dig(:course, :study_mode) ? {} : { study_mode: [I18n.t('activemodel.errors.models.publish/course_study_mode_form.attributes.study_mode.blank')] }
      end

      def previous_tda_course_path?
        params[:previous_tda_course] == 'true'
      end
    end
  end
end
