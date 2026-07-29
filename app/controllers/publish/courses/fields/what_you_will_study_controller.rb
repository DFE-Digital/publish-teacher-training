# frozen_string_literal: true

module Publish
  module Courses
    module Fields
      class WhatYouWillStudyController < BaseController
        include CopyCourseContent
        before_action :authorise_user

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
          section_name = CourseEnrichment.human_attribute_name("what_you_will_study")

          if @what_you_will_study_form.invalid?
            fetch_course_list_to_copy_from
            render :edit
          elsif confirm_live_changes_if_required!(
            section_name:,
            form: @what_you_will_study_form,
            form_param_key: :publish_fields_what_you_will_study_form,
          )
            # rendered interstitial
          elsif @what_you_will_study_form.save!
            course_updated_message section_name
            redirect_after_edit
          end
        end

      private

        def what_you_will_study_params
          params.require(:publish_fields_what_you_will_study_form).permit(*Publish::Fields::WhatYouWillStudyForm::FIELDS)
        end

        def authorise_user
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

        def goto_preview?
          params.dig(:publish_fields_what_you_will_study_form, :goto_preview) == "true"
        end
      end
    end
  end
end
