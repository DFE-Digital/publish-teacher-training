module FeatureHelpers
  module PublishInterfacePages
    def provider_details_show_page
      @provider_details_show_page ||= PageObjects::PublishInterface::ProviderDetailsShow.new
    end

    def provider_details_edit_page
      @provider_details_edit_page ||= PageObjects::PublishInterface::ProviderDetailsEdit.new
    end

    def provider_contact_details_edit_page
      @provider_contact_details_edit_page ||= PageObjects::PublishInterface::ProviderContactDetailsEdit.new
    end
  end
end
