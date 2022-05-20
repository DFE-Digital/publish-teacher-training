# frozen_string_literal: true

module PageObjects
  module Publish
    class ProvidersShow < PageObjects::Base
      set_url "/publish/organisations/{provider_code}"

      element :about_your_organisation, '[data-qa="about-your-organisation"]'
      element :locations, '[data-qa="locations"]'
      element :courses, '[data-qa="courses"]'
      element :users, ".app-status-box"
      element :accredited_courses, '[data-qa="courses-as-an-accredited-body"]'
      element :allocations, '[data-qa="allocations"]'

      # The new elements introduced with the new publish navigation are below. When the feature flag is removed the
      # duplicated elements above can be removed.

      element :nav_organisation_details, :link, "Organisation details"
      element :nav_locations, :link, "Locations"
      element :nav_courses, :link, "Courses"
      element :nav_users, :link, "Users"
      element :nav_training_partners, :link, "Training partners"
    end
  end
end
