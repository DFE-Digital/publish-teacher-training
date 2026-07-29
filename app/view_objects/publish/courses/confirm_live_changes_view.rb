# frozen_string_literal: true

module Publish
  module Courses
    class ConfirmLiveChangesView
      attr_reader :course,
                  :section_name,
                  :form,
                  :form_param_key,
                  :fields,
                  :update_path,
                  :back_path,
                  :cancel_path,
                  :method,
                  :extra_hidden_fields

      def initialize(course:, section_name:, form:, form_param_key:, fields:, update_path:, back_path:, cancel_path:, method:, extra_hidden_fields:)
        @course = course
        @section_name = section_name
        @form = form
        @form_param_key = form_param_key
        @fields = Array(fields)
        @update_path = update_path
        @back_path = back_path
        @cancel_path = cancel_path
        @method = method
        @extra_hidden_fields = extra_hidden_fields
      end

      def page_title
        I18n.t("publish.courses.confirm_live_changes.page_title", section: section_name)
      end

      def heading
        I18n.t("publish.courses.confirm_live_changes.heading", section: section_name)
      end

      def body
        I18n.t("publish.courses.confirm_live_changes.body")
      end

      def continue_label
        I18n.t("publish.courses.confirm_live_changes.continue")
      end

      delegate :name_and_code, to: :course, prefix: true

      def each_hidden_field(&block)
        fields.each do |field|
          value = form.public_send(field)

          if value.is_a?(Array)
            value.each do |item|
              yield "#{form_param_key}[#{field}][]", item
            end
          else
            yield "#{form_param_key}[#{field}]", value
          end
        end

        extra_hidden_fields.each(&block)
      end
    end
  end
end
