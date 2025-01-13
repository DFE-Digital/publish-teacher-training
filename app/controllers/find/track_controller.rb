# frozen_string_literal: true

module Find
  class TrackController < ApplicationController
    def track_click
      utm_content = params[:utm_content]
      url = params[:url]

      Find::TrackClick.new(request:).track_click(utm_content:, url:)

      redirect_to url, allow_other_host: true
    end
  end
end
