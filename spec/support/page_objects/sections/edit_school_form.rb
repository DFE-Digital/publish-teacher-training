# frozen_string_literal: true

require_relative 'base'

module PageObjects
  module Sections
    class EditSchoolForm < PageObjects::Sections::Base
      element :location_name, '#publish-school-form-location-name-field'
      element :urn, '#publish-school-form-urn-field'
      element :code, '#publish-school-form-code-field'
      element :building_and_street, '#publish-school-form-address1-field'
      element :town_or_city, '#publish-school-form-address3-field'
      element :postcode, '#publish-school-form-postcode-field'
    end
  end
end
