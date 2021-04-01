# frozen_string_literal: true

module FeatureHelpers
  module Pages
    def provider_index_page
      @provider_index_page ||= PageObjects::Support::ProviderIndex.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end
  end
end
