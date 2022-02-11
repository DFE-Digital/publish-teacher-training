module FeatureHelpers
  module PublishPages
    def provider_details_show_page
      @provider_details_show_page ||= PageObjects::Publish::ProviderDetailsShow.new
    end

    def provider_details_edit_page
      @provider_details_edit_page ||= PageObjects::Publish::ProviderDetailsEdit.new
    end

    def provider_contact_details_edit_page
      @provider_contact_details_edit_page ||= PageObjects::Publish::ProviderContactDetailsEdit.new
    end

    def visa_sponsorships_page
      @visa_sponsorships_page ||= PageObjects::Publish::ProviderVisaSponsorships.new
    end

    def publish_locations_index_page
      @publish_locations_index_page ||= PageObjects::Publish::LocationsIndex.new
    end

    def publish_location_new_page
      @publish_location_new_page ||= PageObjects::Publish::LocationNew.new
    end

    def publish_location_edit_page
      @publish_location_edit_page ||= PageObjects::Publish::LocationEdit.new
    end

    def provider_users_page
      @provider_users_page ||= PageObjects::Publish::ProviderUsers.new
    end

    def request_access_new_page
      @request_access_new_page ||= PageObjects::Publish::RequestAccessNew.new
    end

    def publish_provider_courses_index_page
      @publish_provider_courses_index_page ||= PageObjects::Publish::ProviderCoursesIndex.new
    end

    def publish_provider_vacancies_edit_page
      @publish_provider_vacancies_edit_page ||= PageObjects::Publish::CourseVacanciesEdit.new
    end

    def publish_provider_courses_show_page
      @publish_provider_courses_show_page ||= PageObjects::Publish::ProviderCoursesShow.new
    end

    def publish_provider_courses_details_page
      @publish_provider_courses_details_page ||= PageObjects::Publish::ProviderCoursesDetails.new
    end
  end
end
