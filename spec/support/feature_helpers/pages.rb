# frozen_string_literal: true

module FeatureHelpers
  module Pages
    def provider_index_page
      @provider_index_page ||= PageObjects::Support::ProviderIndex.new
    end

    def provider_show_page
      @provider_show_page ||= PageObjects::Support::ProviderShow.new
    end

    def provider_users_index_page
      @provider_users_index_page ||= PageObjects::Support::ProviderUsersIndex.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end
  end
end
