# frozen_string_literal: true

module Support
  module Candidates
    class EmailAlertsController < Support::ApplicationController
      include ::Courses::ActiveFilters::SummaryRowBuilder
      helper_method :build_summary_rows

      before_action :set_candidate
      before_action :set_email_alert, only: %i[confirm_unsubscribe unsubscribe]

      def index
        @email_alerts = @candidate.email_alerts.order(created_at: :desc)
      end

      def confirm_unsubscribe; end

      def unsubscribe
        @email_alert.unsubscribe!
        redirect_to support_candidate_email_alerts_path(@candidate),
                    flash: { success: t(".success") }
      end

    private

      def set_candidate
        @candidate = Candidate.find(params[:candidate_id])
      end

      def set_email_alert
        @email_alert = @candidate.email_alerts.find(params[:id])
      end
    end
  end
end
