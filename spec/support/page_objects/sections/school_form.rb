# frozen_string_literal: true

require_relative 'base'

module PageObjects
  module Sections
    class SchoolForm < PageObjects::Sections::Base
      element :location_name, '#site-location-name-field'
      element :urn, '#site-urn-field'
      element :code, '#site-code-field'
      element :building_and_street, '#support-location-form-address1-field'
      element :town_or_city, '#support-location-form-address3-field'
      element :postcode, '#support-location-form-postcode-field'
    end
  end
end
