# frozen_string_literal: true

module PageObjects
  module Publish
    class PrimaryNav < PageObjects::Base
      element :organisation_details, :link, 'Organisation details'
      element :locations, :link, 'Locations'
      element :courses, :link, 'Courses'
      element :users, :link, 'Users'
      element :accredited_bodies, :link, 'Training partners'
    end
  end
end
