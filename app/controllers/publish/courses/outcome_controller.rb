# frozen_string_literal: true

module Publish
  module Courses
    class OutcomeController < PublishController
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

      def new
        super
      end

      def edit
        super
      end

      def update
        authorize(provider)

        @errors = errors
        return render :edit if @errors.present?

        @current_qualification = @course.qualification
        @updated_qualification = params.dig(:course, :qualification)

        if @course.update(course_params)
          handle_qualification_update
        else
          handle_update_failure
        end
      end

      private

      def current_step
        :outcome
      end

      def errors
        params.dig(:course, :qualification) ? {} : { qualification: ['Select a qualification'] }
      end

      def handle_qualification_update
        if undergraduate_to_other_qualification?

          @course.enrichments.find_or_initialize_draft.update(course_length: nil, salary_details: nil)

          redirect_to funding_type_publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code,
            previous_tda_course: true
          )
        else
          if undergraduate_degree_with_qts?
            Publish::Courses::AssignTdaAttributesService.new(@course).call
            @course.save
          end

          redirect_to details_publish_provider_recruitment_cycle_course_path(
            @course.provider_code,
            @course.recruitment_cycle_year,
            @course.course_code
          )

          course_updated_message('Qualification')
        end
      end

      def handle_update_failure
        @errors = @course.errors.messages
        render :edit
      end

      def undergraduate_degree_with_qts?
        @updated_qualification == 'undergraduate_degree_with_qts'
      end

      def undergraduate_to_other_qualification?
        @current_qualification == 'undergraduate_degree_with_qts' && @updated_qualification != 'undergraduate_degree_with_qts'
      end

      def handle_redirect
        if previously_chosen_tda?
          redirect_to new_publish_provider_recruitment_cycle_courses_funding_type_path(path_params.merge(previous_tda_course: true))
        else
          redirect_to next_step
        end
      end

      def previously_chosen_tda?
        params[:current_qualification] == 'undergraduate_degree_with_qts' && params[:goto_confirmation] == 'true'
      end
    end
  end
end
