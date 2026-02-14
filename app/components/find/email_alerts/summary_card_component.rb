# frozen_string_literal: true

module Find
  module EmailAlerts
    class SummaryCardComponent < ViewComponent::Base
      def initialize(email_alert:)
        super
        @email_alert = email_alert
        @attrs = email_alert.search_attributes || {}
      end

      def title
        render(Find::Courses::SearchTitleComponent.new(
                 subjects: resolved_subject_names,
                 location_name: @email_alert.location_name,
                 radius: @email_alert.radius,
                 search_attributes: @attrs,
               ))
      end

      def filter_rows
        @filter_rows ||= build_filter_rows
      end

      def unsubscribe_path
        token = @email_alert.signed_id(purpose: :unsubscribe, expires_in: 30.days)
        helpers.find_candidate_confirm_unsubscribe_email_alert_path(token:)
      end

      private

      def resolved_subject_names
        return [] if @email_alert.subjects.blank?

        Subject.where(subject_code: @email_alert.subjects).pluck(:subject_name)
      end

      def build_filter_rows
        rows = []
        subject_names = resolved_subject_names
        rows << { key: "Subjects", value: subject_names.join(", ") } if subject_names.present?
        rows << { key: "Location", value: location_value } if @email_alert.location_name.present?
        rows << { key: "Visa sponsorship", value: "Yes" } if @attrs["can_sponsor_visa"].present?
        rows.concat(funding_rows)
        rows << { key: "SEND courses", value: "Yes" } if @attrs["send_courses"].present?
        rows << { key: "Level", value: @attrs["level"].humanize } if @attrs["level"].present?
        rows
      end

      def location_value
        if @email_alert.radius.present?
          "Within #{@email_alert.radius} miles of #{@email_alert.location_name}"
        else
          @email_alert.location_name
        end
      end

      def funding_rows
        Array(@attrs["funding"]).filter_map do |f|
          case f
          when "salary" then { key: "Funding", value: "Salary" }
          when "apprenticeship" then { key: "Funding", value: "Apprenticeship" }
          when "fee" then { key: "Funding", value: "Fee" }
          end
        end
      end
    end
  end
end
