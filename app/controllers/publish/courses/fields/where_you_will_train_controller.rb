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
          section_name = "Where you will train"

          if @where_you_will_train_form.invalid?
            fetch_course_list_to_copy_from
            render :edit
          elsif confirm_live_changes_if_required!(
            section_name:,
            form: @where_you_will_train_form,
            form_param_key: :publish_fields_where_you_will_train_form,
          )
            # rendered interstitial
          elsif @where_you_will_train_form.save!
            course_updated_message section_name
            redirect_after_edit
          end
        end

      private

        def where_you_will_train_params
          params
            .expect(publish_fields_where_you_will_train_form: [*Publish::Fields::WhereYouWillTrainForm::FIELDS])
        end

        def goto_preview?
          params.dig(:publish_fields_where_you_will_train_form, :goto_preview) == "true"
        end
      end
    end
  end
end
