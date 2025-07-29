# frozen_string_literal: true

module Find
  class TrackController < ApplicationController
    ALLOWED_REDIRECT_HOSTS = %w[
      gov.uk
      getintoteaching.education.gov.uk
      education-ni.gov.uk
      teachinscotland.scot
      educators.wales
    ].freeze

    def track_click
      utm_content = params[:utm_content]
      url = params[:url]

      track_click_event(utm_content, url)

      redirect_to safe_redirect_url(url), allow_other_host: true
    end

    def track_apply_to_course_click
      utm_content = params[:utm_content]
      url = params[:url]

      track_click_event(utm_content, url)
      send_candidate_applies_analytics_event(params[:course_id])

      redirect_to safe_redirect_url(url), allow_other_host: true
    end

  private

    def track_click_event(utm_content, url)
      Analytics::ClickEvent.new(utm_content:, url:, request: request).send_event
    end

    def send_candidate_applies_analytics_event(course_id)
      Analytics::CandidateAppliesEvent.new(
        request: request,
        candidate_id: @candidate&.id,
        course_id: course_id,
      ).send_event
    end

    def host_allowed?(host)
      ALLOWED_REDIRECT_HOSTS.include?(host)
    end

    def safe_redirect_url(url)
      return find_root_path if url.blank?

      uri = URI.parse(url)

      return url if uri.relative? || host_allowed?(uri.host)

      find_root_path
    rescue URI::InvalidURIError => e
      Sentry.capture_exception(e)
      find_root_path
    end
  end
end
