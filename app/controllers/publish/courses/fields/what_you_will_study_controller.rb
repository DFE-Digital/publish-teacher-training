# app/controllers/publish/courses/fields/what_you_will_study_controller.rb
module Publish
  module Courses
    module Fields
      class WhatYouWillStudyController < ApplicationController
        include CopyCourseContent
        before_action :authorise_with_pundit
        def edit
          @what_you_will_study_form = Publish::Fields::WhatYouWillStudyForm.new(
            course_enrichment,
          )
          @copied_fields = copy_content_check(::Courses::Copy::WHAT_YOU_WILL_STUDY_FIELDS)
          @copied_fields_values = copied_fields_values if @copied_fields.present?

          @what_you_will_study_form.valid? if show_errors_on_publish?
        end

        def update
          @what_you_will_study_form = Publish::Fields::WhatYouWillStudyForm.new(
            course_enrichment,
            params: what_you_will_study_params,
          )
          if @what_you_will_study_form.save!
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
          params.require(:publish_fields_what_you_will_study_form).permit(*Publish::Fields::WhatYouWillStudyForm::FIELDS)
        end

        def authorise_with_pundit
          authorize course_to_authorise
        end

        def course_to_authorise
          @course_to_authorise ||= provider.courses.find_by!(course_code: params[:code])
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
