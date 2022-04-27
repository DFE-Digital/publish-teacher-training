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
      @new_level_page ||= PageObjects::Publish::Courses::NewLevel.new
    end

    def new_subjects_page
      @new_subjects_page ||= PageObjects::Publish::Courses::NewSubjects.new
    end

    def subjects_edit_page
      @subjects_edit_page ||= PageObjects::Publish::Courses::SubjectsEdit.new
    end

    def new_modern_languages_page
      @new_modern_languages_page ||= PageObjects::Publish::Courses::NewModernLanguages.new
    end

    def modern_languages_edit_page
      @modern_languages_edit_page ||= PageObjects::Publish::Courses::ModernLanguagesEdit.new
    end

    def new_age_range_page
      @new_age_range_page ||= PageObjects::Publish::Courses::NewAgeRange.new
    end

    def publish_course_age_range_page
      @publish_course_age_range_page ||= PageObjects::Publish::Courses::AgeRangeEdit.new
    end

    def new_accredited_body_page
      @new_accredited_body_page ||= PageObjects::Publish::Courses::NewAccreditedBody.new
    end

    def new_outcome_page
      @new_outcome_page ||= PageObjects::Publish::Courses::NewOutcome.new
    end

    def new_fee_or_salary_page
      @new_fee_or_salary_page ||= PageObjects::Publish::Courses::NewFeeOrSalary.new
    end

    def new_apprenticeship_page
      @new_apprenticeship_page ||= PageObjects::Publish::Courses::NewApprenticeship.new
    end

    def new_study_mode_page
      @new_study_mode_page ||= PageObjects::Publish::Courses::NewStudyMode.new
    end

    def new_applications_open_page
      @new_applications_open_page ||= PageObjects::Publish::Courses::NewApplicationsOpen.new
    end

    def new_start_date_page
      @new_start_date_page ||= PageObjects::Publish::Courses::NewStartDate.new
    end

    def new_entry_requirements_page
      @new_entry_requirements_page ||= PageObjects::Publish::Courses::NewEntryRequirements.new
    end

    def new_locations_page
      @new_locations_page ||= PageObjects::Publish::Courses::NewLocations.new
    end

    def confirmation_page
      @confirmation_page ||= PageObjects::Publish::CourseConfirmation.new
    end

    def publish_course_information_page
      @publish_course_information_page ||= PageObjects::Publish::CourseInformationEdit.new
    end

    def publish_course_fee_page
      @publish_course_fee_page ||= PageObjects::Publish::CourseFeeEdit.new
    end

    def publish_course_salary_page
      @publish_course_salary_page ||= PageObjects::Publish::CourseSalaryEdit.new
    end

    def publish_course_requirements_page
      @publish_course_requirements_page ||= PageObjects::Publish::CourseRequirementEdit.new
    end

    def publish_course_location_page
      @publish_course_location_page ||= PageObjects::Publish::CourseLocationEdit.new
    end

    def publish_course_preview_page
      @publish_course_preview_page ||= PageObjects::Publish::CoursePreview.new
    end

    def publish_degree_start_page
      @publish_degree_start_page ||= PageObjects::Publish::DegreeStart.new
    end

    def publish_degree_grade_page
      @publish_degree_grade_page ||= PageObjects::Publish::DegreeGrade.new
    end

    def publish_degree_subject_requirement_page
      @publish_degree_subject_requirement_page ||= PageObjects::Publish::DegreeSubjectRequirement.new
    end

    def publish_course_study_mode_page
      @publish_course_study_mode_page ||= PageObjects::Publish::CourseStudyModeEdit.new
    end

    def publish_course_outcome_page
      @publish_course_outcome_page ||= PageObjects::Publish::Courses::OutcomeEditPage.new
    end

    def publish_course_withdrawal_page
      @publish_course_withdrawal_page ||= PageObjects::Publish::Courses::WithdrawalPage.new
    end

    def publish_course_deletion_page
      @publish_course_deletion_page ||= PageObjects::Publish::Courses::DeletePage.new
    end

    def gcse_requirements_page
      @gcse_requirements_page ||= PageObjects::Publish::Courses::GcseRequirementsPage.new
    end

    def training_providers_page
      @training_providers_page ||= PageObjects::Publish::TrainingProviderIndex.new
    end

    def training_provider_courses_page
      @training_provider_courses_page ||= PageObjects::Publish::TrainingProviders::CourseIndex.new
    end

    def allocations_page
      @allocations_page ||= PageObjects::Publish::Allocations::AllocationsPage.new
    end

    def publish_allocations_show_page
      @publish_allocations_show_page ||= PageObjects::Publish::Allocations::AllocationsShowPage.new
    end

    def who_are_you_requesting_a_course_for_page
      @who_are_you_requesting_a_course_for_page ||= PageObjects::Publish::Allocations::Request::WhoAreYouRequestingACourseForPage.new
    end

    def number_of_places_page
      @number_of_places_page ||= PageObjects::Publish::Allocations::Request::NumberOfPlacesPage.new
    end

    def check_your_info_page
      @check_your_info_page ||= PageObjects::Publish::Allocations::Request::CheckYourInfoPage.new
    end

    def pick_a_provider_page
      @pick_a_provider_page ||= PageObjects::Publish::Allocations::Request::PickAProviderPage.new
    end

    def publish_providers_show_page
      @publish_providers_show_page ||= PageObjects::Publish::ProvidersShow.new
    end

    def publish_providers_index_page
      @publish_providers_index_page ||= PageObjects::Publish::ProvidersIndex.new
    end

    def terms_and_conditions_page
      @terms_and_conditions_page ||= PageObjects::Publish::Terms.new
    end

    def rollover_page
      @rollover_page ||= PageObjects::Publish::Rollover.new
    end

    def rollover_recruitment_page
      @rollover_recruitment_page ||= PageObjects::Publish::RolloverRecruitment.new
    end

    def notifications_page
      @notifications_page ||= PageObjects::Publish::Notification.new
    end

    def header
      @header ||= PageObjects::Publish::Header.new
    end
  end
end
