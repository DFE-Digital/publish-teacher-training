# frozen_string_literal: true

module Courses
  # Value object representing the location a candidate provided when
  # searching for courses. Owns the single question every consumer was
  # previously re-implementing: "does this search have a location we can
  # actually sort by distance from?".
  class SearchLocation
    def self.from_params(params)
      params = params.with_indifferent_access
      new(
        text: params[:location],
        latitude: params[:latitude],
        longitude: params[:longitude],
        formatted_address: params[:formatted_address],
        short_address: params[:short_address],
      )
    end

    def initialize(text: nil, latitude: nil, longitude: nil,
                   formatted_address: nil, short_address: nil)
      @text = text
      @latitude = latitude
      @longitude = longitude
      @formatted_address = formatted_address
      @short_address = short_address
    end

    def sortable_by_distance?
      @latitude.present? && @longitude.present?
    end

    def blank?
      [@text, @formatted_address, @short_address].all?(&:blank?) &&
        !sortable_by_distance?
    end

    def label
      [@short_address, @formatted_address, @text].find(&:present?)
    end
  end
end
