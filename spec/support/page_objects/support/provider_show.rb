# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderShow < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/providers/{id}"

      element :users_tab, ".app-tab-navigation__link", text: "Users"
      element :courses_tab, ".app-tab-navigation__link", text: "Courses"

      element :edit_provider_name, "a", text: "Change"
      element :edit_provider_accrediting_body, "a", text: "Change"
      element :edit_provider_type, "a", text: "Change"
    end
  end
end
