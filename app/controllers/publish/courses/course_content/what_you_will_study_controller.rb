# app/controllers/publish/courses/course_content/what_you_will_study_controller.rb
module Publish
  module Courses
    module CourseContent
      class WhatYouWillStudyController < ApplicationController
        include CopyCourseContent
        before_action :authorise_with_pundit
        def edit
          @course_content_what_you_will_study_form = Publish::CourseContentWhatYouWillStudyForm.new(
            course_enrichment,
          )
          @copied_fields = copy_content_check(Publish::CourseContentWhatYouWillStudyForm::WHAT_YOU_WILL_STUDY_FIELDS)
          @copied_fields_values = copied_fields_values if @copied_fields.present?

          @course_content_what_you_will_study_form.valid? if show_errors_on_publish?
        end

        def update
          @course_content_what_you_will_study_form = Publish::CourseContentWhatYouWillStudyForm.new(
            course_enrichment,
            params: what_you_will_study_params,
          )
          if @course_content_what_you_will_study_form.save!
            course_updated_message CourseEnrichment.human_attribute_name("what_you_will_study")
            redirect_to publish_provider_recruitment_cycle_course_path(provider.provider_code,
                                                                       recruitment_cycle.year,
                                                                       course.course_code)

          else
            fetch_course_list_to_copy_from
            render :edit
          end
        end

      private

        def what_you_will_study_params
          params.require(:publish_course_content_what_you_will_study_form).permit(*CourseContentWhatYouWillStudyForm::FIELDS)
        end

        def authorise_with_pundit
          authorize course_to_authorise
        end

        def course_to_authorise
          @course_to_authorise ||= provider.courses.find_by!(course_code: params[:course_code])
        end

        def course
          @course ||= CourseDecorator.new(course_to_authorise)
        end

        def course_enrichment
          @course_enrichment ||= course.enrichments.find_or_initialize_draft
        end
      end
    end
  end
end
