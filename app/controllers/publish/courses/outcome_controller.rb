# frozen_string_literal: true

module Publish
  module Courses
    class OutcomeController < PublishController
      include CourseBasicDetailConcern
      before_action :order_edit_options, only: %i[edit new]

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

        if @course.update(course_params)
          course_updated_message('Qualification')

          redirect_to(
            details_publish_provider_recruitment_cycle_course_path(
              @course.provider_code,
              @course.recruitment_cycle_year,
              @course.course_code
            )
          )
        else
          @errors = @course.errors.messages
          render :edit
        end
      end

      private

      def order_edit_options
        qualification_options = @course.edit_course_options[:qualifications]
        @course.edit_course_options[:qualifications] = if @course.level == 'further_education'
                                                         non_qts_qualifications(qualification_options)
                                                       else
                                                         qts_qualifications(qualification_options)
                                                       end
      end

      def current_step
        :outcome
      end

      def qts_qualifications(edit_options)
        options = %w[pgce_with_qts qts pgde_with_qts tda_with_qts]

        raise 'Non QTS qualification options do not match' if edit_options.sort != options.sort

        options
      end

      def non_qts_qualifications(edit_options)
        options = %w[pgce pgde tda]

        raise 'QTS qualification options do not match' if edit_options.sort != options.sort

        options
      end

      def errors
        params.dig(:course, :qualification) ? {} : { qualification: ['Select a qualification'] }
      end
    end
  end
end
