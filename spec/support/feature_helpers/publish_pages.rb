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

    def new_level_page
      @new_level_page ||= PageObjects::PublishInterface::Courses::NewLevel.new
    end

    def new_subjects_page
      @new_subjects_page ||= PageObjects::PublishInterface::Courses::NewSubjects.new
    end

    def new_modern_languages_page
      @new_modern_languages_page ||= PageObjects::PublishInterface::Courses::NewModernLanguages.new
    end

    def new_age_range_page
      @new_age_range_page ||= PageObjects::PublishInterface::Courses::NewAgeRange.new
    end

    def new_accredited_body_page
      @new_accredited_body_page ||= PageObjects::PublishInterface::Courses::NewAccreditedBody.new
    end

    def new_outcome_page
      @new_outcome_page ||= PageObjects::PublishInterface::Courses::NewOutcome.new
    end

    def new_fee_or_salary_page
      @new_fee_or_salary_page ||= PageObjects::PublishInterface::Courses::NewFeeOrSalary.new
    end

    def new_apprenticeship_page
      @new_apprenticeship_page ||= PageObjects::PublishInterface::Courses::NewApprenticeship.new
    end

    def new_study_mode_page
      @new_study_mode_page ||= PageObjects::PublishInterface::Courses::NewStudyMode.new
    end

    def new_applications_open_page
      @new_applications_open_page ||= PageObjects::PublishInterface::Courses::NewApplicationsOpen.new
    end

    def new_start_date_page
      @new_start_date_page ||= PageObjects::PublishInterface::Courses::NewStartDate.new
    end

    def new_entry_requirements_page
      @new_entry_requirements_page ||= PageObjects::PublishInterface::Courses::NewEntryRequirements.new
    end

    def new_locations_page
      @new_locations_page ||= PageObjects::PublishInterface::Courses::NewLocations.new
    end

    def confirmation_page
      @confirmation_page ||= PageObjects::PublishInterface::CourseConfirmation.new
    end
  end
end
