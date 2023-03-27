# frozen_string_literal: true

require_relative 'base'

module PageObjects
  module Sections
    class LocationForm < PageObjects::Sections::Base
      element :location_name, '#support-location-form-location-name-field'
      element :urn, '#support-location-form-urn-field'
      element :code, '#support-location-code-field'
      element :building_and_street, '#support-location-form-address1-field'
      element :town_or_city, '#support-location-form-address3-field'
      element :postcode, '#support-location-form-postcode-field'
    end
  end
end
