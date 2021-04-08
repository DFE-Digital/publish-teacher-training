# frozen_string_literal: true

module PageObjects
  module Support
    class ProviderShow < PageObjects::Base
      set_url "/support/providers/{id}"

      element :users_tab, ".app-tab-navigation__link", text: "Users"
      element :courses_tab, ".app-tab-navigation__link", text: "Courses"

      element :edit_provider, "a", text: "Change"
    end
  end
end
