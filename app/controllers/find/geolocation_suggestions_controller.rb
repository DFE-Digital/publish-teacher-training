# frozen_string_literal: true

module Find
  class GeolocationSuggestionsController < ApplicationController
    def index
      return render(json: [], status: :bad_request) if params[:query].blank?

      render json: { suggestions: Geolocation::Suggestions.new(params[:query]).call }
    end
  end
end
