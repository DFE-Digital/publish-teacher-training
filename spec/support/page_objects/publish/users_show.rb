# frozen_string_literal: true

module PageObjects
  module Publish
    class UsersShow < PageObjects::Base
      set_url "/publish/organisations/{provider_code}/users/{id}"
    end
  end
end
