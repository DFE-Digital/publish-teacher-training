# frozen_string_literal: true

module Publish
  module Courses
    module Fields
      class WhereYouWillTrainController < ApplicationController
        include CopyCourseContent
        before_action :authorise_with_pundit

        def edit
          @where_you_will_train_form = Publish::Fields::WhereYouWillTrainForm.new(course_enrichment)
          # @copied_fields = copy_content_check(::Courses::Copy::V2_WHERE_YOU_WILL_TRAIN_FIELDS)

          # @copied_fields_values = copied_fields_values if @copied_fields.present?
          @where_you_will_train_form.valid? if show_errors_on_publish?
        end

        def update
          @where_you_will_train_form = Publish::Fields::WhereYouWillTrainForm.new(
            course_enrichment,
            params: where_you_will_train_params,
          )

          if @where_you_will_train_form.save!
            course_updated_message "Where you will train"

            redirect_to publish_provider_recruitment_cycle_course_path(
              provider.provider_code,
              recruitment_cycle.year,
              course.course_code,
            )

          else
            fetch_course_list_to_copy_from
            render :edit
          end
        end

      private

        def where_you_will_train_params
          params
            .expect(publish_fields_where_you_will_train_form: [*Publish::Fields::WhereYouWillTrainForm::FIELDS])
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
