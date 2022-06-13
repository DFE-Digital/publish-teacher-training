# frozen_string_literal: true

module FeatureHelpers
  module SupportPages
    def provider_index_page
      @provider_index_page ||= PageObjects::Support::ProviderIndex.new
    end

    def support_provider_show_page
      @provider_show_page ||= PageObjects::Support::ProviderShow.new
    end

    def support_provider_new_page
      @provider_new_page ||= PageObjects::Support::ProviderNew.new
    end

    def support_provider_edit_page
      @provider_edit_page ||= PageObjects::Support::ProviderEdit.new
    end

    def support_provider_users_index_page
      @provider_users_index_page ||= PageObjects::Support::ProviderUsersIndex.new
    end

    def support_provider_courses_index_page
      @provider_courses_index_page ||= PageObjects::Support::Provider::CoursesIndex.new
    end

    def support_provider_locations_index_page
      @provider_locations_index_page ||= PageObjects::Support::Provider::LocationsIndex.new
    end

    def support_provider_location_create_page
      @provider_location_create_page ||= PageObjects::Support::Provider::LocationCreate.new
    end

    def support_provider_location_edit_page
      @provider_location_edit_page ||= PageObjects::Support::Provider::LocationEdit.new
    end

    def support_course_edit_page
      @course_edit_page ||= PageObjects::Support::Provider::CourseEdit.new
    end

    def support_users_show_page
      @users_show_page ||= PageObjects::Support::UserShow.new
    end

    def support_users_show_providers_page
      @users_show_providers_page ||= PageObjects::Support::UserShowProviders.new
    end

    def support_users_index_page
      @users_index_page ||= PageObjects::Support::UsersIndex.new
    end

    def support_user_new_page
      @user_new_page ||= PageObjects::Support::UserNew.new
    end

    def support_user_edit_page
      @user_edit_page ||= PageObjects::Support::UserEdit.new
    end

    def support_allocations_index_page
      @allocations_index_page ||= PageObjects::Support::AllocationsIndex.new
    end

    def support_allocations_show_page
      @allocations_show_page ||= PageObjects::Support::AllocationsShow.new
    end

    def support_allocation_uplift_edit_page
      @allocation_uplift_edit_page ||= PageObjects::Support::AllocationUpliftEdit.new
    end

    def support_allocation_uplift_new_page
      @allocation_uplift_new_page ||= PageObjects::Support::AllocationUpliftNew.new
    end

    def support_access_requests_page
      @access_requests_page ||= PageObjects::Support::AccessRequests::Index.new
    end

    def support_access_requests_confirm_page
      @access_requests_confirm_page ||= PageObjects::Support::AccessRequests::Confirm.new
    end

    def support_sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end
  end
end
