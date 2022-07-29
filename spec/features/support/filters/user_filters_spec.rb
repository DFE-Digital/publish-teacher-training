# frozen_string_literal: true

require "rails_helper"

feature "Filter users" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_are_users
    when_i_visit_the_support_users_index_page
  end

  context "adding filters" do
    scenario "by users name" do
      then_i_can_search_by_first_name
      and_when_i_click_apply_filters
      the_correct_admin_user_shows
    end

    scenario "by users email" do
      then_i_can_search_by_email
      and_when_i_click_apply_filters
      the_correct_admin_user_shows
    end

    scenario "by user type" do
      then_i_select_provider_user_checkbox
      and_when_i_click_apply_filters
      the_correct_provider_user_shows
    end
  end

  context "removing filters" do
    before do
      given_i_have_filters_selected
    end

    scenario "removing selected filters" do
      i_can_remove_filters
      and_i_can_see_unfiltered_results
    end
  end

private

  def and_there_are_users
    @user = create(:user)
    @admin_user = create(:user, :admin)
  end

  def when_i_visit_the_support_users_index_page
    support_users_index_page.load(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
  end

  def then_i_can_search_by_first_name
    support_users_index_page.name_or_email_search.set(@admin_user.first_name)
  end

  def then_i_can_search_by_email
    support_users_index_page.name_or_email_search.set(@admin_user.email)
  end

  def then_i_select_provider_user_checkbox
    support_users_index_page.provider_user_checkbox.check
  end

  def and_when_i_click_apply_filters
    support_users_index_page.apply_filters.click
  end

  def the_correct_admin_user_shows
    expect(support_users_index_page.users.length).to eq(1)
    expect(support_users_index_page).to have_content(@admin_user.first_name)
    expect(support_users_index_page).not_to have_content(@user.first_name)
  end

  def the_correct_provider_user_shows
    expect(support_users_index_page.users.length).to eq(1)
    expect(support_users_index_page).to have_content(@user.first_name)
    expect(support_users_index_page).not_to have_content(@admin_user.first_name)
  end

  def given_i_have_filters_selected
    then_i_can_search_by_first_name
    then_i_select_provider_user_checkbox
    and_when_i_click_apply_filters
  end

  def i_can_remove_filters
    support_users_index_page.remove_filters.click
  end

  def and_i_can_see_unfiltered_results
    expect(support_users_index_page.users.length).to eq 3
    expect(support_users_index_page).to have_content(@admin_user.first_name)
    expect(support_users_index_page).to have_content(@user.first_name)
  end
end
