# frozen_string_literal: true

module Find
  module EmailAlerts
    class SummaryCardComponent < ViewComponent::Base
      include ::Courses::ActiveFilters::SummaryRowBuilder

      def initialize(email_alert:, subject_names:)
        super()
        @email_alert = email_alert
        @attrs = email_alert.search_attributes || {}
        @subject_names = subject_names
      end

      def title
        Find::Courses::SearchTitleComponent.new(
          subjects: @subject_names,
          location_name: @email_alert.location_name,
          radius: @email_alert.radius,
          search_attributes: @attrs,
        ).title_text
      end

      def filter_rows
        @filter_rows ||= build_summary_rows(
          @attrs.merge("radius" => @email_alert.radius, "location" => @email_alert.location_name),
          subject_names: @subject_names,
        )
      end

      def unsubscribe_path
        token = @email_alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)
        helpers.find_candidate_confirm_unsubscribe_email_alert_path(token:)
      end
    end
  end
end
