# frozen_string_literal: true

module PageObjects
  module Publish
    class Header < PageObjects::Base
      element :notifications_preference_link, "a.govuk-header__link", text: "Notifications"
      element :active_notifications_preference_link, "li.govuk-header__navigation-item a.govuk-header__link", text: "Notifications"
    end
  end
end
