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
        all_subject_codes = @email_alerts.flat_map { |a| subject_codes_for(a) }.uniq
        @subject_names_by_code = Subject.where(subject_code: all_subject_codes).pluck(:subject_code, :subject_name).to_h
      end

      def confirm_unsubscribe
        @subject_names = Subject.where(subject_code: subject_codes_for(@email_alert)).pluck(:subject_name)
      end

      def unsubscribe
        @email_alert.unsubscribe!
        redirect_to support_candidate_email_alerts_path(@candidate),
                    flash: { success: t(".success") }
      end

    private

      def set_candidate
        @candidate = ::Candidate.find(params[:candidate_id])
      end

      def set_email_alert
        @email_alert = @candidate.email_alerts.find(params[:id])
      end

      def subject_codes_for(alert)
        codes = alert.subjects.dup
        code = alert.search_attributes&.dig("subject_code")
        codes << code if code.present?
        codes
      end
    end
  end
end
