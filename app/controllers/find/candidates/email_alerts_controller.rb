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
        @title = build_title(@search_params)
        @filter_tags = build_filter_tags(@search_params)
      end

      def create
        alert = Find::CreateEmailAlertService.call(
          candidate: @candidate,
          search_params: search_params_from_request,
        )

        if alert
          flash[:success_with_body] = {
            "title" => t(".success_title"),
            "body" => t(".success_body_html",
                        title: alert_title_text(alert),
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
        @filter_tags = build_filter_tags_from_alert(@email_alert)
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
        @filter_tags = build_filter_tags_from_alert(@email_alert)
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

      def build_title(search_params)
        subject_names = resolve_subject_names(search_params[:subjects])
        location = search_params[:location] || search_params[:formatted_address]

        render_to_string(
          Find::Courses::SearchTitleComponent.new(
            subjects: subject_names,
            location_name: location,
            radius: search_params[:radius],
            search_attributes: search_params.to_h,
          ),
        ).strip
      end

      def alert_title_text(alert)
        subject_names = resolve_subject_names(alert.subjects)
        if subject_names.any?
          subject_names.to_sentence
        elsif alert.location_name.present?
          "courses near #{alert.location_name}"
        else
          "courses"
        end
      end

      def resolve_subject_names(codes)
        return [] if codes.blank?

        Subject.where(subject_code: Array(codes)).pluck(:subject_name)
      end

      def build_filter_tags(search_params)
        tags = []
        tags.concat(resolve_subject_names(search_params[:subjects]))
        tags << location_tag(search_params) if (search_params[:location] || search_params[:formatted_address]).present?
        tags << "Visa sponsorship" if search_params[:can_sponsor_visa].present?
        tags.concat(funding_tags(search_params[:funding]))
        tags << "SEND courses" if search_params[:send_courses].present?
        tags << search_params[:level].humanize if search_params[:level].present?
        tags.compact
      end

      def build_filter_tags_from_alert(alert)
        tags = []
        tags.concat(resolve_subject_names(alert.subjects))
        tags << location_tag_from_alert(alert) if alert.location_name.present?
        attrs = alert.search_attributes || {}
        tags << "Visa sponsorship" if attrs["can_sponsor_visa"].present?
        tags.concat(funding_tags(attrs["funding"]))
        tags << "SEND courses" if attrs["send_courses"].present?
        tags << attrs["level"].humanize if attrs["level"].present?
        tags.compact
      end

      def location_tag(search_params)
        name = search_params[:location] || search_params[:formatted_address]
        radius = search_params[:radius]
        radius.present? ? "Within #{radius} miles of #{name}" : name
      end

      def location_tag_from_alert(alert)
        alert.radius.present? ? "Within #{alert.radius} miles of #{alert.location_name}" : alert.location_name
      end

      FUNDING_LABELS = {
        "salary" => "Salary",
        "apprenticeship" => "Apprenticeship",
        "fee" => "Fee",
      }.freeze

      def funding_tags(funding)
        Array(funding).filter_map { |f| FUNDING_LABELS[f] }
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
