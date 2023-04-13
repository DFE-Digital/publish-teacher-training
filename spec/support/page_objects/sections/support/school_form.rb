# frozen_string_literal: true

require_relative '../base'

module PageObjects
  module Sections
    module Support
      class SchoolForm < PageObjects::Sections::Base
        element :location_name, '#support-school-form-location-name-field'
        element :urn, '#support-school-form-urn-field'
        element :code, '#support-school-form-code-field'
        element :building_and_street, '#support-school-form-address1-field'
        element :town_or_city, '#support-school-form-town-field'
        element :postcode, '#support-school-form-postcode-field'
      end
    end
  end
end
