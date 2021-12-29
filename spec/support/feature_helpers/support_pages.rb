# frozen_string_literal: true

module FeatureHelpers
  module SupportPages
    def provider_index_page
      @provider_index_page ||= PageObjects::Support::ProviderIndex.new
    end

    def provider_show_page
      @provider_show_page ||= PageObjects::Support::ProviderShow.new
    end

    def provider_new_page
      @provider_new_page ||= PageObjects::Support::ProviderNew.new
    end

    def provider_edit_page
      @provider_edit_page ||= PageObjects::Support::ProviderEdit.new
    end

    def provider_users_index_page
      @provider_users_index_page ||= PageObjects::Support::ProviderUsersIndex.new
    end

    def provider_courses_index_page
      @provider_courses_index_page ||= PageObjects::Support::Provider::CoursesIndex.new
    end

    def provider_locations_index_page
      @provider_locations_index_page ||= PageObjects::Support::Provider::LocationsIndex.new
    end

    def course_edit_page
      @course_edit_page ||= PageObjects::Support::Provider::CourseEdit.new
    end

    def users_show_page
      @users_show_page ||= PageObjects::Support::UserShow.new
    end

    def users_index_page
      @users_index_page ||= PageObjects::Support::UsersIndex.new
    end

    def user_new_page
      @user_new_page ||= PageObjects::Support::UserNew.new
    end

    def allocations_index_page
      @allocations_index_page ||= PageObjects::Support::AllocationsIndex.new
    end

    def allocations_show_page
      @allocations_show_page ||= PageObjects::Support::AllocationsShow.new
    end

    def allocation_uplift_edit_page
      @allocation_uplift_edit_page ||= PageObjects::Support::AllocationUpliftEdit.new
    end

    def allocation_uplift_new_page
      @allocation_uplift_new_page ||= PageObjects::Support::AllocationUpliftNew.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end
  end
end
