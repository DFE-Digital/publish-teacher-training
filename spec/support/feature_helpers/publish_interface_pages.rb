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

    def visa_sponsorships_page
      @visa_sponsorships_page ||= PageObjects::PublishInterface::ProviderVisaSponsorships.new
    end

    def publish_locations_index_page
      @publish_locations_index_page ||= PageObjects::PublishInterface::LocationsIndex.new
    end

    def publish_location_new_page
      @publish_location_new_page ||= PageObjects::PublishInterface::LocationNew.new
    end

    def publish_location_edit_page
      @publish_location_edit_page ||= PageObjects::PublishInterface::LocationEdit.new
    end

    def provider_users_page
      @provider_users_page ||= PageObjects::PublishInterface::ProviderUsers.new
    end

    def request_access_new_page
      @request_access_new_page ||= PageObjects::PublishInterface::RequestAccessNew.new
    end

    def publish_provider_courses_index_page
      @publish_provider_courses_index_page ||= PageObjects::PublishInterface::ProviderCoursesIndex.new
    end
  end
end
