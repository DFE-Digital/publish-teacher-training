# frozen_string_literal: true

require "rails_helper"

feature "Viewing a user" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
  end

  scenario "viewing a users details" do
    and_there_is_a_user
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
    i_can_see_a_list_of_users
    and_i_click_on_the_user
    then_i_am_directed_to_the_provider_user_show_page
    and_i_see_the_users_details
  end

  scenario "with last login information" do
    and_there_is_a_user(with_previous_login)
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
    i_can_see_a_list_of_users
    and_i_click_on_the_user
    then_i_am_directed_to_the_provider_user_show_page
    and_i_see_the_users_details_with_last_login
  end

private

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(id: @user.providers.first.id)
  end

  def and_there_is_a_user(user = nil)
    @user = user || create(:user, :with_provider)
    @user.providers << create(:provider)
  end

  def with_previous_login
    create(:user, :with_provider, last_login_date_utc: Time.zone.yesterday)
  end

  def and_click_on_the_users_tab
    support_provider_show_page.users_tab.click
  end

  def i_can_see_a_list_of_users
    expect(support_provider_users_index_page.users.first.full_name.text).to eq(@user.full_name)
  end

  def and_i_click_on_the_user
    support_provider_users_index_page.users.first.full_name.click
  end

  def then_i_am_directed_to_the_provider_user_show_page
    expect(support_provider_user_show_page).to be_displayed
  end

  def and_i_see_the_users_details
    expect(support_provider_user_show_page.first_name.text).to eq(@user.first_name)
    expect(support_provider_user_show_page.last_name.text).to eq(@user.last_name)
    expect(support_provider_user_show_page.email.text).to eq(@user.email)
    expect(support_provider_user_show_page.organisations.text).to eq(@user.providers.pluck(:provider_name).join)
  end

  def and_i_see_the_users_details_with_last_login
    and_i_see_the_users_details
    expect(support_provider_user_show_page.date_last_signed_in.text).to eq(@user.last_login_date_utc.strftime("%d %B %Y at %I:%M%p"))
  end
end
