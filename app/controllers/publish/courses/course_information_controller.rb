module Publish
  module Courses
    class CourseInformationController < PublishController
      include CourseBasicDetailConcern

      def edit
        authorize(provider)

        @course_information_form = CourseInformationForm.new(course_enrichment)

        fetch_course_list_to_copy_from

        if params[:copy_from].present?
          fetch_course_to_copy_from
          @copied_fields = ::Courses::Copy.get_present_fields_in_source_course(::Courses::Copy::ABOUT_FIELDS, @source_course, @course)
        end
      end

      def update
        authorize(provider)

        @course_information_form = CourseInformationForm.new(course_enrichment, params: course_information_params)

        if @course_information_form.save!
          flash[:success] = I18n.t("success.saved")

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

      def fetch_course_to_copy_from
        @source_course = ::Courses::Fetch.by_code(
          provider_code: params[:provider_code],
          course_code: params[:copy_from]
        )
      end

      def fetch_course_list_to_copy_from
        @courses_by_accrediting_provider = ::Courses::Fetch.by_accrediting_provider(@provider)
        @self_accredited_courses = @courses_by_accrediting_provider.delete(@provider.provider_name)

        @courses_by_accrediting_provider = @courses_by_accrediting_provider.reject { |c| c == course.id }
        @self_accredited_courses = @self_accredited_courses&.reject { |c| c.id == course.id }
      end

      def build_course
        super
        authorize @course
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
