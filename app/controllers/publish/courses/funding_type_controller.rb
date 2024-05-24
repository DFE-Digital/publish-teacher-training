# frozen_string_literal: true

module Publish
  module Courses
    class FundingTypeController < PublishController
      include CourseBasicDetailConcern

      def continue
        authorize(@provider, :can_create_course?)
        @errors = errors
        if @errors.any?
          render :new
        else
          handle_redirect
        end
      end

      def edit
        authorize(course, :can_update_funding_type?)
        @course_funding_form = CourseFundingForm.new(@course)
        @course_funding_form.clear_stash
      end

      def update
        authorize(course, :can_update_funding_type?)

        @course_funding_form = CourseFundingForm.new(@course, params: funding_type_params)

        if @course_funding_form.valid?
          handle_valid_form
        else
          handle_invalid_form
        end
      end

      private

      def funding_type_params
        return {} if params[:publish_course_funding_form].blank?

        params.require(:publish_course_funding_form).permit(:funding_type, :previous_tda_course)
      end

      def handle_valid_form
        if previous_tda_course?
          process_previous_tda_course
        else
          redirect_to next_path
        end
      end

      def handle_invalid_form
        @errors = @course_funding_form.errors.messages
        render :edit
      end

      def previous_tda_course?
        params[:publish_course_funding_form][:previous_tda_course] == 'true'
      end

      def process_previous_tda_course
        @course_funding_form.save! if @course_funding_form.funding_type_updated?
        redirect_to full_part_time_publish_provider_recruitment_cycle_course_path(
          provider_code: course.provider_code,
          recruitment_cycle_year: course.recruitment_cycle_year,
          course_code: course.course_code,
          previous_tda_course: true
        )
      end

      def next_path
        if @course_funding_form.funding_type_updated?
          @course_funding_form.stash
          visa_page_path
        else
          course_updated_message(section_key)
          course_page_path
        end
      end

      def visa_sponsorship_path
        if course.is_fee_based?
          new_publish_provider_recruitment_cycle_courses_student_visa_sponsorship_path(path_params)
        else
          new_publish_provider_recruitment_cycle_courses_skilled_worker_visa_sponsorship_path(path_params)
        end
      end

      def current_step
        :funding_type
      end

      def error_keys
        %i[funding_type program_type]
      end

      def course_values
        {
          provider_code: course.provider_code,
          recruitment_cycle_year: course.recruitment_cycle_year,
          course_code: course.course_code
        }
      end

      def visa_page_path
        if @course_funding_form.student_visa?
          student_visa_sponsorship_publish_provider_recruitment_cycle_course_path(course_values)
        else
          skilled_worker_visa_sponsorship_publish_provider_recruitment_cycle_course_path(course_values)
        end
      end

      def course_page_path
        details_publish_provider_recruitment_cycle_course_path(course_values)
      end

      def section_key
        'Funding type'
      end

      def handle_redirect
        if goto_visa_path?
          redirect_to visa_sponsorship_path
        elsif previous_tda_course_path?
          redirect_to previously_defaulted_attributes
        else
          redirect_to next_step
        end
      end

      def goto_visa_path?
        params[:goto_visa] == 'true' && params[:course][:previous_tda_course] != 'true'
      end

      def previous_tda_course_path?
        params[:course][:previous_tda_course] == 'true'
      end

      def previously_defaulted_attributes
        new_publish_provider_recruitment_cycle_courses_study_mode_path(path_params.merge(previous_tda_course: 'true'))
      end
    end
  end
end
