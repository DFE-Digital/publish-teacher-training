# frozen_string_literal: true

module Find
  module EmailAlerts
    class SummaryCardComponent < ViewComponent::Base
      include ::Courses::ActiveFilters::SummaryRowBuilder

      def initialize(email_alert:)
        super()
        @email_alert = email_alert
        @attrs = email_alert.search_attributes || {}
      end

      def title
        Find::Courses::SearchTitleComponent.new(
          subjects: resolved_subject_names,
          location_name: @email_alert.location_name,
          radius: @email_alert.radius,
          search_attributes: @attrs,
        ).title_text
      end

      def filter_rows
        @filter_rows ||= build_summary_rows(
          @attrs.merge("radius" => @email_alert.radius, "location" => @email_alert.location_name),
          subject_names: resolved_subject_names,
        )
      end

      def unsubscribe_path
        token = @email_alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)
        helpers.find_candidate_confirm_unsubscribe_email_alert_path(token:)
      end

    private

      def resolved_subject_names
        @resolved_subject_names ||= begin
          return [] if @email_alert.subjects.blank?

          Subject.where(subject_code: @email_alert.subjects).pluck(:subject_name)
        end
      end
    end
  end
end
