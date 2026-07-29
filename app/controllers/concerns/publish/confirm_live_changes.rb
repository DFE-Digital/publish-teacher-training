# frozen_string_literal: true

module Publish
  module ConfirmLiveChanges
    extend ActiveSupport::Concern

    CONFIRM_PUBLISH_PARAM = "true"

  private

    def require_live_changes_confirmation?
      course_for_live_changes_confirmation&.is_published? &&
        params[:confirm_publish] != CONFIRM_PUBLISH_PARAM
    end

    # Returns true (and renders the interstitial) when a published course edit
    # still needs confirmation. Returns false when the caller should save.
    #
    # Paths default to the current request path (edit + update share a URL for
    # most course sections). Fields default to form.class::FIELDS when present.
    def confirm_live_changes_if_required!(section_name:, form:, form_param_key:, fields: nil, method: nil, update_path: nil, back_path: nil, cancel_path: nil, extra_hidden_fields: {})
      return false unless require_live_changes_confirmation?

      render_live_changes_confirmation(
        section_name:,
        form:,
        form_param_key:,
        fields: fields || fields_for_live_changes_form(form),
        method: method || request_method_for_live_changes,
        update_path: update_path || request.path,
        back_path: back_path || request.path,
        cancel_path: cancel_path || default_cancel_path_for_live_changes,
        extra_hidden_fields: default_extra_hidden_fields_for_live_changes(form_param_key).merge(extra_hidden_fields).compact,
      )
      true
    end

    def render_live_changes_confirmation(section_name:, form:, form_param_key:, fields:, update_path:, back_path:, cancel_path:, method: :patch, extra_hidden_fields: {})
      @confirm_live_changes = Publish::Courses::ConfirmLiveChangesView.new(
        course: course_for_live_changes_confirmation,
        section_name:,
        form:,
        form_param_key:,
        fields:,
        update_path:,
        back_path:,
        cancel_path:,
        method:,
        extra_hidden_fields:,
      )

      render "publish/courses/confirm_live_changes/show"
    end

    def course_for_live_changes_confirmation
      if respond_to?(:course, true)
        course
      elsif instance_variable_defined?(:@course)
        @course
      end
    end

    def fields_for_live_changes_form(form)
      form.class::FIELDS if form.class.const_defined?(:FIELDS)
    end

    def request_method_for_live_changes
      request.request_method.downcase.to_sym
    end

    def default_cancel_path_for_live_changes
      course = course_for_live_changes_confirmation
      publish_provider_recruitment_cycle_course_path(
        course.provider_code,
        course.recruitment_cycle_year,
        course.course_code,
      )
    end

    def default_extra_hidden_fields_for_live_changes(form_param_key)
      {
        "#{form_param_key}[goto_preview]" => params.dig(form_param_key, :goto_preview).presence || params[:goto_preview],
      }
    end
  end
end
