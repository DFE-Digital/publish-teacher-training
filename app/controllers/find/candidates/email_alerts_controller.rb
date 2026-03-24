# frozen_string_literal: true

module Find
  module Candidates
    class EmailAlertsController < ApplicationController
      include ::Courses::ActiveFilters::SummaryRowBuilder

      before_action :require_authentication, except: %i[unsubscribe_from_email confirm_unsubscribe_from_email]
      before_action :redirect_if_subscription_limit_reached, only: %i[new create]

      def index
        @email_alerts = @candidate.email_alerts.active.order(created_at: :desc)
        all_codes = @email_alerts.flat_map(&:subjects).compact.uniq
        @subject_names_by_code = all_codes.any? ? Subject.where(subject_code: all_codes).pluck(:subject_code, :subject_name).to_h : {}
      end

      def new
        return redirect_existing_alert if existing_alert?

        @title = build_title(subject_names:, search_attributes: search_params.to_h, location_name:, radius: search_params[:radius])
        @summary_rows = build_summary_rows(search_params.to_h, subject_names:)
        @search_params = search_params
        @cancel_path = redirect_after_create
      end

      def create
        alert = Find::CreateEmailAlertService.call(
          candidate: @candidate,
          search_params:,
        )

        if alert
          title = build_title(
            subject_names: resolve_subject_names(alert.subjects),
            search_attributes: alert.search_attributes || {},
            location_name: alert.location_name,
            radius: alert.radius,
          )
          flash[:success_with_body] = {
            "title" => t(".success_title"),
            "body" => t(".success_body_html", title:),
          }
          redirect_to redirect_after_create
        else
          flash[:warning] = t(".create_failed")
          redirect_to find_candidate_email_alerts_path
        end
      end

      def confirm_unsubscribe
        @email_alert = find_alert_by_token
        @filter_tags = extract_filter_tags_from_alert(@email_alert)
      end

      def unsubscribe
        alert = find_alert_by_token
        alert.unsubscribe!

        flash[:success_with_body] = {
          "title" => t(".success_title"),
          "body" => t(".success_body"),
        }
        redirect_to find_candidate_email_alerts_path
      end

      def unsubscribe_from_email
        @email_alert = Candidate::EmailAlert.find_signed!(params[:token], purpose: :unsubscribe)
        @filter_tags = extract_filter_tags_from_alert(@email_alert)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to find_root_path
      end

      def confirm_unsubscribe_from_email
        alert = Candidate::EmailAlert.find_signed!(params[:token], purpose: :unsubscribe)
        alert.unsubscribe!

        flash[:success_with_body] = {
          "title" => t("find.candidates.email_alerts.unsubscribe.success_title"),
          "body" => t("find.candidates.email_alerts.unsubscribe.success_body"),
        }
        redirect_to find_root_path
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to find_root_path
      end

    private

      def reason_for_request
        :general
      end

      def search_params
        @search_params ||= search_params_from_request
      end

      def subject_names
        @subject_names ||= resolve_subject_names(search_params[:subjects])
      end

      def location_name
        search_params[:location] || search_params[:formatted_address]
      end

      def existing_alert?
        digest = compute_digest_from_params
        @candidate.email_alerts.active.exists?(filter_key_digest: digest)
      end

      def compute_digest_from_params
        Find::FilterKeyDigest.digest(
          subjects: search_params[:subjects],
          search_attributes: search_params.to_h,
        )
      end

      def redirect_existing_alert
        flash[:info] = t("find.candidates.email_alerts.new.already_subscribed")
        redirect_to redirect_after_create
      end

      def build_title(subject_names:, search_attributes:, location_name:, radius:)
        Find::Courses::SearchTitleComponent.new(
          subjects: subject_names,
          location_name:,
          radius:,
          search_attributes:,
        ).title_text
      end

      def find_alert_by_token
        alert = Candidate::EmailAlert.find_signed!(params[:token], purpose: :unsubscribe)
        raise ActiveRecord::RecordNotFound unless alert.candidate_id == @candidate.id

        alert
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        raise ActiveRecord::RecordNotFound
      end

      def search_params_from_request
        params.permit(
          :applications_open, :can_sponsor_visa, :engineers_teach_physics,
          :formatted_address, :funding, :interview_location, :level,
          :location, :longitude, :latitude, :minimum_degree_required,
          :order, :provider_code, :provider_name, :radius, :return_to,
          :send_courses, :subject_code,
          subjects: [], study_types: [], qualifications: [], start_date: []
        )
      end

      def resolve_subject_names(codes)
        return [] if codes.blank?

        Subject.where(subject_code: Array(codes)).pluck(:subject_name)
      end

      def extract_filter_tags(attrs, subject_names: [])
        ::Courses::ActiveFilters::HashExtractor.new(
          attrs,
          subject_names:,
          provider_name: attrs["provider_name"],
        ).call.map(&:formatted_value)
      end

      def extract_filter_tags_from_alert(alert)
        attrs = (alert.search_attributes || {}).merge(
          "radius" => alert.radius,
          "location" => alert.location_name,
        )
        extract_filter_tags(attrs, subject_names: resolve_subject_names(alert.subjects))
      end

      def redirect_if_subscription_limit_reached
        email_alert = @candidate.email_alerts.build
        email_alert.valid?
        return unless email_alert.errors.of_kind?(:base, :subscription_limit_reached)

        link = helpers.govuk_link_to(
          t("find.candidates.email_alerts.new.subscription_limit_link_text"),
          find_candidate_email_alerts_path,
          target: "_blank",
        )
        flash[:info] = {
          "title" => t("find.candidates.email_alerts.new.subscription_limit_heading"),
          "body" => t("find.candidates.email_alerts.new.subscription_limit_body_html", link:),
        }
        redirect_to redirect_after_create
      end

      def redirect_after_create
        if params[:return_to] == "recent_searches"
          find_candidate_recent_searches_path
        else
          find_results_path(search_params.except(:return_to))
        end
      end
    end
  end
end
