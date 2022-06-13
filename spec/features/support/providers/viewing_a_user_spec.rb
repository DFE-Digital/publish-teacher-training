# frozen_string_literal: true

require "rails_helper"

feature "Viewing a user" do
  before do
    given_i_am_authenticated(user: create(:user, :admin))
    and_there_is_a_user
    when_i_visit_the_support_provider_show_page
    and_click_on_the_users_tab
    i_can_see_a_list_of_users
    and_i_click_on_the_user
  end

  scenario "i am directed to the user show page" do
    then_i_am_directed_to_the_user_show_page
  end

  def when_i_visit_the_support_provider_show_page
    support_provider_show_page.load(id: @user.providers.first.id)
  end

  def and_there_is_a_user
    @user = create(:user, :with_provider)
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

  def then_i_am_directed_to_the_user_show_page
    expect(support_users_show_page).to be_displayed
    expect(support_users_show_page.first_name.text).to eq @user.first_name
    expect(support_users_show_page.last_name.text).to eq @user.last_name
    expect(support_users_show_page.email.text).to eq @user.email
    expect(support_users_show_page.admin_status.text).to eq "False"
  end
end
