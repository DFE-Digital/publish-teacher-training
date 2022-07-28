# frozen_string_literal: true

module PageObjects
  module Support
    class UsersIndex < PageObjects::Base
      set_url "/support/{recruitment_cycle_year}/users"

      element :add_a_user, "a", text: "Add a user"

      # Filter elements
      element :apply_filters, "input.govuk-button"
      element :name_or_email_search, "#text_search.govuk-input"
      element :provider_user_checkbox, "#user_type-provider.govuk-checkboxes__input"
      element :remove_filters, "a.govuk-link", text: "Clear"

      sections :users, PageObjects::Sections::User, ".user-row"
    end
  end
end
