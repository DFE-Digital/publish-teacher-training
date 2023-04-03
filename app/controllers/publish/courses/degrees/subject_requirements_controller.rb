# frozen_string_literal: true

module Publish
  module Courses
    module Degrees
      class SubjectRequirementsController < PublishController
        include CopyCourseContent
        include GotoPreview

        decorates_assigned :source_course
        before_action :redirect_to_course_details_page_if_course_is_primary

        def edit
          authorize(provider)

          set_backlink
          @subject_requirements_form = SubjectRequirementForm.build_from_course(course)
          copy_boolean_check(::Courses::Copy::SUBJECT_REQUIREMENTS_FIELDS)
        end

        def update
          authorize(provider)

          @subject_requirements_form = SubjectRequirementForm.new(subject_requirements_params)

          if @subject_requirements_form.valid? && !goto_preview?
            @subject_requirements_form.save(@course)
            course_updated_message('Degree requirements')
            redirect_to publish_provider_recruitment_cycle_course_path
          elsif @subject_requirements_form.valid? && goto_preview?
            @subject_requirements_form.save(@course)
            redirect_to preview_publish_provider_recruitment_cycle_course_path(provider.provider_code, course.recruitment_cycle_year, course.course_code)
          else
            set_backlink
            @errors = @subject_requirements_form.errors.messages
            render :edit
          end
        end

        private

        def param_form_key = :publish_subject_requirement_form

        def course
          @course ||= CourseDecorator.new(provider.courses.find_by!(course_code: params[:code]))
        end

        def subject_requirements_params
          params
            .require(param_form_key)
            .except(:goto_preview)
            .permit(:additional_degree_subject_requirements, :degree_subject_requirements)
        end

        def set_backlink
          @backlink = if course.degree_grade == 'not_required'
                        degrees_start_publish_provider_recruitment_cycle_course_path
                      elsif gobackto_preview?
                        degrees_grade_publish_provider_recruitment_cycle_course_path(goto_preview: true)
                      else
                        degrees_grade_publish_provider_recruitment_cycle_course_path
                      end
        end

        def gobackto_preview?
          params[:goto_preview] == 'true' || params.dig(param_form_key, :goto_preview)
        end

        def redirect_to_course_details_page_if_course_is_primary
          redirect_to publish_provider_recruitment_cycle_course_path if course.is_primary?
        end
      end
    end
  end
end
