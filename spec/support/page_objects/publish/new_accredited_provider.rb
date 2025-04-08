# frozen_string_literal: true

module PageObjects
  module Publish
    class NewAccreditedProvider < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/{recruitment_cycle_year}/accredited-provider/new{?query*}"

      elements :suggested_accredited_partners, '[data-qa="course__accredited_provider_option"]'

      element :about_section_input, "textarea"
      element :submit, 'button[type="submit"]'
    end
  end
end
