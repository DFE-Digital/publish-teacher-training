module Publish
  module Courses
    module Degrees
      class SubjectRequirementsController < PublishController
        before_action :redirect_to_course_details_page_if_course_is_primary

        def edit
          authorize(provider)

          set_backlink
          @subject_requirements_form = SubjectRequirementForm.build_from_course(course)
        end

        def update
          authorize(provider)

          @subject_requirements_form = SubjectRequirementForm.new(subject_requirements_params)

          if @subject_requirements_form.save(@course)
            flash[:success] = I18n.t("success.saved")

            redirect_to publish_provider_recruitment_cycle_course_path
          else
            set_backlink
            @errors = @subject_requirements_form.errors.messages
            render :edit
          end
        end

      private

        def course
          @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
        end

        def subject_requirements_params
          params
            .require(:publish_subject_requirement_form)
            .permit(:additional_degree_subject_requirements, :degree_subject_requirements)
        end

        def set_backlink
          @backlink = if course.degree_grade == "not_required"
                        degrees_start_publish_provider_recruitment_cycle_course_path
                      else
                        degrees_grade_publish_provider_recruitment_cycle_course_path
                      end
        end

        def redirect_to_course_details_page_if_course_is_primary
          redirect_to publish_provider_recruitment_cycle_course_path if course.is_primary?
        end
      end
    end
  end
end
