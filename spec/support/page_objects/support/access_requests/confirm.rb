# frozen_string_literal: true

module PageObjects
  module Support
    module AccessRequests
      class Confirm < PageObjects::Base
        set_url "/publish/access-requests/{id}/confirm"

        element :approve, '[data-qa="access-request__approve"]'
        element :delete, '[data-qa="access-request__delete"]'
      end
    end
  end
end
