# frozen_string_literal: true

module PageObjects
  module Publish
    class Footer < PageObjects::Base
      element :access_requests_link, '[data-qa="access_requests_link"]'
    end
  end
end
