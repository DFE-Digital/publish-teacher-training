# frozen_string_literal: true

module Find
  module Candidates
    class EmailAlertsController < ApplicationController
      before_action :require_authentication, except: %i[unsubscribe_from_email confirm_unsubscribe_from_email]

      def index
        @email_alerts = @candidate.email_alerts.active.order(created_at: :desc)
      end

      def new
        @search_params = search_params_from_request
        subject_names = resolve_subject_names(@search_params[:subjects])
        @title = render_to_string(
          Find::Courses::SearchTitleComponent.new(
            subjects: subject_names,
            location_name: @search_params[:location] || @search_params[:formatted_address],
            radius: @search_params[:radius],
            search_attributes: @search_params.to_h,
          ),
        ).strip
        @filter_tags = extract_filter_tags(@search_params.to_h, subject_names:)
      end

      def create
        alert = Find::CreateEmailAlertService.call(
          candidate: @candidate,
          search_params: search_params_from_request,
        )

        if alert
          subject_names = resolve_subject_names(alert.subjects)
          title = if subject_names.any?
                    subject_names.to_sentence
                  elsif alert.location_name.present?
                    "courses near #{alert.location_name}"
                  else
                    "courses"
                  end
          flash[:success_with_body] = {
            "title" => t(".success_title"),
            "body" => t(".success_body_html",
                        title:,
                        link: helpers.govuk_link_to(t(".view_email_alerts"), find_candidate_email_alerts_path)),
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
        @email_alert = EmailAlert.find_signed!(params[:token], purpose: :unsubscribe)
        @filter_tags = extract_filter_tags_from_alert(@email_alert)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to find_root_path
      end

      def confirm_unsubscribe_from_email
        alert = EmailAlert.find_signed!(params[:token], purpose: :unsubscribe)
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

      def find_alert_by_token
        alert = EmailAlert.find_signed!(params[:token], purpose: :unsubscribe)
        raise ActiveRecord::RecordNotFound unless alert.candidate_id == @candidate.id

        alert
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        raise ActiveRecord::RecordNotFound
      end

      def search_params_from_request
        params.permit(
          :can_sponsor_visa, :funding, :level, :location, :longitude,
          :latitude, :radius, :send_courses, :minimum_degree_required,
          :formatted_address, :provider_name, :return_to,
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

      def redirect_after_create
        if params[:return_to] == "recent_searches"
          find_candidate_recent_searches_path
        else
          find_results_path(search_params_from_request.except(:return_to))
        end
      end
    end
  end
end
