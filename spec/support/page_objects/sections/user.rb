# frozen_string_literal: true

require_relative "base"

module PageObjects
  module Sections
    class User < PageObjects::Sections::Base
      element :full_name, ".govuk-table__cell:first-child .govuk-link"
      element :email, ".govuk-table__cell:nth-child(2)"
      element :last_signed_in, ".last-signed-in"
      element :remove_user_link, ".remove-user .govuk-link"
    end
  end
end
