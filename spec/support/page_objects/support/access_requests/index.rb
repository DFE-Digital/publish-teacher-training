# frozen_string_literal: true

module PageObjects
  module Support
    module AccessRequests
      class Index < PageObjects::Base
        set_url "/publish/access-requests"

        sections :requests, '[data-qa="access-request"]' do
          element :id, '[data-qa="access-request__id"]'
          element :date, '[data-qa="access-request__request_date"]'
          element :requester, '[data-qa="access-request__requester"]'
          element :recipient, '[data-qa="access-request__recipient"]'
          element :view_request, '[data-qa="access-request__view_request"]'
          element :organisation, '[data-qa="access-request__organisation"]'
        end
      end
    end
  end
end
