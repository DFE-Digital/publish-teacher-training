# frozen_string_literal: true

module Publish
  module Courses
    module Fields
      class WhereYouWillTrainController < BaseController
        def edit
          @where_you_will_train_form = Publish::Fields::WhereYouWillTrainForm.new(course_enrichment)
          @copied_fields = copy_content_check(::Courses::Copy::V2_WHERE_YOU_WILL_TRAIN_FIELDS)

          @copied_fields_values = copied_fields_values if @copied_fields.present?
          @where_you_will_train_form.valid? if show_errors_on_publish?
        end

        def update
          @where_you_will_train_form = Publish::Fields::WhereYouWillTrainForm.new(
            course_enrichment,
            params: where_you_will_train_params,
          )

          if @where_you_will_train_form.save!
            course_updated_message "Where you will train"

            if params["publish_fields_where_you_will_train_form"][:goto_preview] == "true"
              redirect_to preview_publish_provider_recruitment_cycle_course_path(
                provider_code: provider.provider_code,
                recruitment_cycle_year: provider.recruitment_cycle_year,
                code: course.course_code,
              )
            else
              redirect_to publish_provider_recruitment_cycle_course_path(
                provider.provider_code,
                recruitment_cycle.year,
                course.course_code,
              )
            end
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
      end
    end
  end
end
