module Publish
  module Courses
    class CourseInformationController < PublishController
      include CopyCourseContent

      def edit
        authorize(provider)

        @course_information_form = CourseInformationForm.new(course_enrichment)
        copy_content_check(::Courses::Copy::ABOUT_FIELDS)

        @course_information_form.valid? if show_errors_on_publish?
      end

      def update
        authorize(provider)

        @course_information_form = CourseInformationForm.new(course_enrichment, params: course_information_params)

        if @course_information_form.save!
          course_description_success_message("course information")

          redirect_to publish_provider_recruitment_cycle_course_path(
            provider.provider_code,
            recruitment_cycle.year,
            course.course_code,
          )
        else
          render :edit
        end
      end

    private

      def course
        @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
      end

      def course_information_params
        params
          .require(:publish_course_information_form)
          .permit(
            CourseInformationForm::FIELDS,
          )
      end

      def course_enrichment
        @course_enrichment ||= course.enrichments.find_or_initialize_draft
      end
    end
  end
end
