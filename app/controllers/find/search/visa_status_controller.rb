# frozen_string_literal: true

module Find
  module Search
    class VisaStatusController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies
      include DefaultApplicationsOpen

      def new
        @visa_status_form = VisaStatusForm.new(visa_status: params[:visa_status])
      end

      def create
        @visa_status_form = VisaStatusForm.new(
          visa_status: form_params[:visa_status]
        )

        if @visa_status_form.valid?
          redirect_to next_step_path
        else
          render :new
        end
      end

      private

      def next_step_path
        if course_type_answer_determiner.not_elibible_for_undergraduate_courses?
          find_no_degree_and_requires_visa_sponsorship_path(filter_params[:find_visa_status_form])
        else
          find_results_path(
            form_params.merge(
              subjects: sanitised_subject_codes,
              has_vacancies: default_vacancies,
              applications_open: default_applications_open,
              can_sponsor_visa: form_params[:visa_status]
            )
          )
        end
      end

      def course_type_answer_determiner
        @course_type_answer_determiner ||= CourseTypeAnswerDeterminer.new(
          university_degree_status: form_params[:university_degree_status],
          age_group: form_params[:age_group],
          visa_status: form_params[:visa_status]
        )
      end

      def sanitised_subject_codes
        form_params['subjects'].compact_blank!
      end

      def form_name = :find_visa_status_form

      def back_path
        return find_university_degree_status_path(backlink_query_parameters) if teacher_degree_apprenticeship_active?

        if params[:age_group] == 'further_education' || (params[:find_visa_status_form] && params[:find_visa_status_form][:age_group] == 'further_education')
          find_age_groups_path(backlink_query_parameters)
        else
          find_subjects_path(backlink_query_parameters)
        end
      end
      helper_method :back_path
    end
  end
end
