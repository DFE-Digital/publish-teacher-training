# frozen_string_literal: true

# When the `new_publish_navigation` feature flag is removed this file along with the associated tests can be deleted.

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
    end
  end
end
