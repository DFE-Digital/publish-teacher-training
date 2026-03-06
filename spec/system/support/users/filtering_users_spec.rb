# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter users by status" do
  let(:admin_user) { create(:user, :admin) }

  before do
    given_i_am_authenticated(user: admin_user)
    and_there_are_users
    when_i_visit_the_support_users_index_page
  end

  scenario "filtering by user type Provider shows only provider users" do
    and_there_are_users_for_user_type_filter
    when_i_select_provider_user_type_filter
    and_i_apply_the_filters
    then_i_see_only_provider_users
  end

  scenario "filtering by user type Admin shows only admin users" do
    and_there_are_users_for_user_type_filter
    when_i_select_admin_user_type_filter
    and_i_apply_the_filters
    then_i_see_only_admin_users
  end

private

  def and_there_are_users
    @user = create(:user, first_name: "User")
    @admin_user = create(:user, :admin, first_name: "AdminUser")
  end

  def when_i_visit_the_support_users_index_page
    support_users_index_page.load(recruitment_cycle_year: Find::CycleTimetable.current_year)
  end

  def and_i_apply_the_filters
    support_users_index_page.apply_filters.click
  end

  def then_i_see_both_users
    expect(page).to have_css(".user-row", text: @user.first_name)
    expect(page).to have_css(".user-row", text: @admin_user.first_name)
  end

  def and_there_are_users_for_user_type_filter
    @provider_user_filter = create(:user, first_name: "ProviderUser")
    @admin_user_filter = create(:user, :admin, first_name: "AdminUser")
  end

  def when_i_select_provider_user_type_filter
    check("user_type-provider")
  end

  def when_i_select_admin_user_type_filter
    check("user_type-admin")
  end

  def then_i_see_only_provider_users
    expect(page).to have_css(".user-row", text: @provider_user_filter.first_name)
    expect(page).to have_no_css(".user-row", text: @admin_user_filter.first_name)
  end

  def then_i_see_only_admin_users
    expect(page).to have_css(".user-row", text: @admin_user_filter.first_name)
    expect(page).to have_no_css(".user-row", text: @provider_user_filter.first_name)
  end
end
