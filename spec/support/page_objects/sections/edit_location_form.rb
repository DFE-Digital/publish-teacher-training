# frozen_string_literal: true

# TODO: remove this when we align edit form
require_relative 'base'

module PageObjects
  module Sections
    class EditLocationForm < PageObjects::Sections::Base
      element :location_name, '#site-location-name-field'
      element :urn, '#site-urn-field'
      element :code, '#site-code-field'
      element :building_and_street, '#site-address1-field'
      element :town_or_city, '#site-address3-field'
      element :postcode, '#site-postcode-field'
    end
  end
end
