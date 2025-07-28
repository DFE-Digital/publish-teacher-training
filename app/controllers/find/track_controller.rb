# frozen_string_literal: true

module Find
  class TrackController < ApplicationController
    def track_click
      utm_content = params[:utm_content]
      url = params[:url]

      track_click_event(utm_content, url)

      redirect_to url, allow_other_host: true
    end

    def track_apply_to_course_click
      utm_content = params[:utm_content]
      url = params[:url]

      track_click_event(utm_content, url)

      send_candidate_applies_analytics_event(params[:course_id])

      redirect_to url, allow_other_host: true
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
  end
end
