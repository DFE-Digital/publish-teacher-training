module PublishInterface
  module Courses
    class OutcomeController < PublishInterfaceController
      include CourseBasicDetailConcern
      before_action :order_edit_options, only: %i[edit new]

      def edit
        super
      end

      def new
        super
      end

    private

      def order_edit_options
        qualification_options = @course.edit_course_options[:qualifications]
        @course.edit_course_options[:qualifications] = if @course.level == "further_education"
                                                          non_qts_qualifications(qualification_options)
                                                        else
                                                          qts_qualifications(qualification_options)
                                                        end
      end

      def current_step
        :outcome
      end

      def qts_qualifications(edit_options)
        options = %w[pgce_with_qts qts pgde_with_qts]

        if edit_options.sort != options.sort
          raise "Non QTS qualification options do not match"
        end

        options
      end

      def non_qts_qualifications(edit_options)
        options = %w[pgce pgde]

        if edit_options.sort != options.sort
          raise "QTS qualification options do not match"
        end

        options
      end

      def errors
        params.dig(:course, :qualification) ? {} : { qualification: ["Pick an outcome"] }
      end
    end
  end
end
